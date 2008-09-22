//
//  MapView.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#if TARGET_OS_IPHONE

#import "RMMapView.h"
#import "RMVirtualEarthSource.h"
#import "RMOpenStreetMapsSource.h"
#import "RMTileImage.h"
#import "RMTile.h"
//#import "TileImageSet.h"
//#import "TiledLayerController.h"
#import "RMFractalTileProjection.h"
#import "RMMemoryCache.h"

#import "RMQuartzRenderer.h"
#import "RMCoreAnimationRenderer.h"

#import "RMScreenProjection.h"

@implementation RMMapView

@synthesize enableDragging, enableZoom, tileSource;

-(void) makeTileSource
{
	if (tileSource != nil)
		return;
	
	tileSource = [[RMOpenStreetMapsSource alloc] init];
}

-(void) makeRenderer
{
	if (tileSource == nil)
	{
		[self makeTileSource];
	}
	
	if (renderer != nil)
		return;
	
//	renderer = [[QuartzRenderer alloc] initWithView:self];
	renderer = [[RMCoreAnimationRenderer alloc] initWithView:self];
}

-(void) configureCaching
{
	// Unfortunately, the iPhone doesn't seem to support disk caches using NSURLCache. This works fine in the
	// simulator though.
	
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
	
	CLLocationCoordinate2D here;
	here.latitude = -33.9464;
	here.longitude = 151.2381;
	[self setScale:10];
	[self setLocation:here];
		
//	[screenProjection setScale:[[[view tileSource] tileProjection] calculateScaleFromZoom:16]];
	
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

-(void) moveToMercator: (RMMercatorPoint) point
{
	[renderer moveToMercator:point];
}
-(void) moveToLatLong: (CLLocationCoordinate2D) point
{
	[renderer moveToLatLong:point];
}

- (void)moveBy: (CGSize) delta
{
	[renderer moveBy:delta];
}
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[renderer zoomByFactor:zoomFactor Near:center];
}

- (CLLocationCoordinate2D) location
{
	RMMercatorRect rect = [[renderer screenProjection] mercatorBounds];
	RMMercatorPoint center = rect.origin;
	center.x += rect.size.width / 2;
	center.y += rect.size.height / 2;
	return [RMMercator toLatLong:center];
}

- (void) setLocation: (CLLocationCoordinate2D) location
{
	[self moveToLatLong:location];
}

- (float) scale
{
	return [[renderer screenProjection] scale];
}

- (void) setScale: (float) scale
{
	[[renderer screenProjection] setScale:scale];
	[renderer setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[renderer drawRect:rect];
}

- (RMGestureDetails) getGestureDetails: (NSSet*) touches
{
	RMGestureDetails gesture;
	gesture.center.x = gesture.center.y = 0;
	gesture.averageDistanceFromCenter = 0;
	
	int interestingTouches = 0;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;
//		NSLog(@"phase = %d", [touch phase]);
		
		interestingTouches++;
		
		CGPoint location = [touch locationInView: self];
		
		gesture.center.x += location.x;
		gesture.center.y += location.y;
	}
	
	if (interestingTouches == 0)
	{
		gesture.center = lastGesture.center;
		gesture.numTouches = 0;
		gesture.averageDistanceFromCenter = 0.0f;
		return gesture;
	}
	
//	NSLog(@"interestingTouches = %d", interestingTouches);
	
	gesture.center.x /= interestingTouches;
	gesture.center.y /= interestingTouches;
	
	for (UITouch *touch in touches)
	{
		if ([touch phase] != UITouchPhaseBegan
			&& [touch phase] != UITouchPhaseMoved
			&& [touch phase] != UITouchPhaseStationary)
			continue;

		CGPoint location = [touch locationInView: self];
		
//		NSLog(@"For touch at %.0f, %.0f:", location.x, location.y);
		float dx = location.x - gesture.center.x;
		float dy = location.y - gesture.center.y;
//		NSLog(@"delta = %.0f, %.0f  distance = %f", dx, dy, sqrtf((dx*dx) + (dy*dy)));
		gesture.averageDistanceFromCenter += sqrtf((dx*dx) + (dy*dy));
	}
	
	gesture.averageDistanceFromCenter /= interestingTouches;

	gesture.numTouches = interestingTouches;
	
//	NSLog(@"center = %.0f,%.0f dist = %f", gesture.center.x, gesture.center.y, gesture.averageDistanceFromCenter);
	
	return gesture;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	NSLog(@"touchesBegan %d", [[event allTouches] count]);
	lastGesture = [self getGestureDetails:[event allTouches]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// I don't understand what the difference between this and touchesEnded is.
	[self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	lastGesture = [self getGestureDetails:[event allTouches]];

//	NSLog(@"touchesEnded %d  ... lastgesture at %f, %f", [[event allTouches] count], lastGesture.center.x, lastGesture.center.y);
	
	//	NSLog(@"Assemble.");
	if (lastGesture.numTouches == 0)
		[renderer recalculateImageSet];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	RMGestureDetails newGesture = [self getGestureDetails:[event allTouches]];

	if (enableDragging && newGesture.numTouches == lastGesture.numTouches)
	{
		CGSize delta;
		delta.width = newGesture.center.x - lastGesture.center.x;
		delta.height = newGesture.center.y - lastGesture.center.y;
	
		if (enableZoom && newGesture.numTouches > 1)
		{
			NSAssert (lastGesture.averageDistanceFromCenter > 0.0f && newGesture.averageDistanceFromCenter > 0.0f,
					  @"Distance from center is zero despite >1 touches on the screen");

			double zoomFactor = newGesture.averageDistanceFromCenter / lastGesture.averageDistanceFromCenter;
			
			[self moveBy:delta];
			[self zoomByFactor: zoomFactor Near: newGesture.center];
		}
		else
		{
			[self moveBy:delta];
		}
		
	}

	lastGesture = newGesture;
}

CGRect cgBounds
{
	return [self bounds];
}

@end

#endif