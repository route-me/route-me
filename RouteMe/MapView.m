//
//  MapView.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "OpenStreetMapsSource.h"
#import "TileImage.h"
#import "Tile.h"
//#import "TileImageSet.h"
//#import "TiledLayerController.h"
#import "FractalTileProjection.h"
#import "MemoryCache.h"

#import "QuartzRenderer.h"
#import "CoreAnimationRenderer.h"

@implementation MapView

@synthesize enableDragging, enableZoom, tileSource;

-(void) makeTileSource
{
	if (tileSource != nil)
		return;
	
	tileSource = [[OpenStreetMapsSource alloc] init];
	tileSource = [[MemoryCache alloc] initWithParentSource:tileSource Capacity:20];
}

-(void) makeRenderer
{
	if (tileSource == nil)
	{
		[self makeTileSource];
	}
	
	if (renderer != nil)
		return;
	
	renderer = [[QuartzRenderer alloc] initWithView:self];
//	renderer = [[CoreAnimationRenderer alloc] initWithView:self];
}

/*
-(void) makeProjection
{
	if (tileSource == nil)
		[self makeTileSource];
	
	screenProjection = [[TiledLayerController alloc] initWithTileSource: tileSource];
	[self layer].masksToBounds = YES;
	[[self layer] addSublayer:[screenProjection layer]];
	[[self layer] setNeedsDisplay];
	
	CLLocationCoordinate2D here;
//	here.latitude = -33.9264;
	here.latitude = -33.9464;
	here.longitude = 151.2381;
	[screenProjection setScale:[[tileSource tileProjection] calculateScaleFromZoom:18]];
	[screenProjection centerLatLong:here Animate: NO];
}*/

-(void) configureCaching
{
	// Unfortunately, the iPhone doesn't seem to support disk caches using NSURLCache. 
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSLocalDomainMask, YES);
	if ([paths count] > 0)
	{
		NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"mapTiles/"];
		NSLog(@"Using cache path: %@", path);
		NSURLCache *newCache = [[NSURLCache alloc] initWithMemoryCapacity:1024 * 1024 diskCapacity:1024 * 1024 * 10
																 diskPath:path];
		[NSURLCache setSharedURLCache:newCache];
		[newCache release];
	}	
}

-(void) initValues
{
	renderer = nil;
	tileSource = nil;
	
	[self makeTileSource];
	[self makeRenderer];
	
//	imageSet = [[TileImageSet alloc] init];
	
	enableDragging = YES;
	enableZoom = YES;
	
//	[self recalculateImageSet];
	
	if (enableZoom)
		[self setMultipleTouchEnabled:TRUE];
	
	[renderer setNeedsDisplay];
	
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self initValues];
	}
	return self;
}

- (void)awakeFromNib
{
	[self initValues];
}

-(void) dealloc
{
	[tileSource release];
	[renderer release];
	
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	[renderer drawRect: rect];
}

/*
- (void)drawRect:(CGRect)rect {
//	imageSet = [tileSource tileImagesForScreen: screenProjection];
	if ([imageSet needsRedraw])
	{
//		[self recalculateImageSet];
		NSLog(@"WARNING - Image set needs redraw and we're in drawRect.");
	}
	[imageSet draw];
	
//	[self setNeedsDisplay];
}*/

- (GestureDetails) getGestureDetails: (NSSet*) touches
{
	GestureDetails gesture;
	gesture.center.x = gesture.center.y = 0;
	gesture.averageDistanceFromCenter = 0;
	
	for (UITouch *touch in touches)
	{
		CGPoint location = [touch locationInView: self];
		
		gesture.center.x += location.x;
		gesture.center.y += location.y;
	}
	
	gesture.center.x /= [touches count];
	gesture.center.y /= [touches count];
	
	for (UITouch *touch in touches)
	{
		CGPoint location = [touch locationInView: self];
		
//		NSLog(@"For touch at %.0f, %.0f:", location.x, location.y);
		float dx = location.x - gesture.center.x;
		float dy = location.y - gesture.center.y;
//		NSLog(@"delta = %.0f, %.0f  distance = %f", dx, dy, sqrtf((dx*dx) + (dy*dy)));
		gesture.averageDistanceFromCenter += sqrtf((dx*dx) + (dy*dy));
	}
	
	gesture.averageDistanceFromCenter /= [touches count];
//	NSLog(@"center = %.0f,%.0f dist = %f", gesture.center.x, gesture.center.y, gesture.averageDistanceFromCenter);
	
	return gesture;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	lastGesture = [self getGestureDetails:[event allTouches]];
}

//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	GestureDetails gesture = [self getGestureDetails:[event allTouches]];
//	lastZoomDistance = gesture.averageDistanceFromCenter;
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	lastGesture = [self getGestureDetails:[event allTouches]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (enableDragging)
	{		
		GestureDetails newGesture = [self getGestureDetails:[event allTouches]];

		CGSize delta;
		delta.width = newGesture.center.x - lastGesture.center.x;
		delta.height = newGesture.center.y - lastGesture.center.y;
	
		if (enableZoom && [[event allTouches] count] > 1)
		{
			// Don't bother sliding the images. We'll need to regenerate the imageset anyway.
//			[self dragBy: delta TrySlideImages: NO];
			[renderer moveBy:delta];
			
			double zoomFactor = lastGesture.averageDistanceFromCenter / newGesture.averageDistanceFromCenter;
//			lastZoomDistance = gesture.averageDistanceFromCenter;
			
//			[imageSet setNeedsRedraw];
			[renderer zoomByFactor: zoomFactor Near: newGesture.center];
		}
		else
		{
//			[self dragBy: delta TrySlideImages: YES];
			[renderer moveBy:delta];
		}
		
//		[self setNeedsDisplay];
		
		lastGesture = newGesture;
	}
	
//	if ([imageSet needsRedraw])
//		[self recalculateImageSet];
}

@end
