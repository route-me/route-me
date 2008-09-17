//
//  Tile.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileImage.h"
#import "WebTileImage.h"
#import "TileLoader.h"
#import "FileTileImage.h"
#import "TileCache.h"
#import "MathUtils.h"
#import <QuartzCore/QuartzCore.h>

NSString * const MapImageLoadedNotification = @"MapImageLoaded";
NSString * const MapImageLoadingCancelledNotification = @"MapImageLoadingCancelled";

@implementation TileImage

@synthesize tile, layer, image;

- (id) initBlankTile: (Tile)_tile
{
	if (![super init])
		return nil;
	
	tile = _tile;
	image = nil;
	layer = nil;
	loadingPriorityCount = 0;
	
	lastUsedTime = [NSDate date];
	return self;	
}

- (id) initWithTile: (Tile)_tile
{
	if (![self initBlankTile: _tile])
		return nil;

	if ([[self class] isEqual:[TileImage class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileImage directly."];
		[self release];
		return nil; 
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tileRemovedFromScreen:)
												 name:MapImageRemovedFromScreenNotification object:self];
	
	// Should this be done as a notification?
	[[TileCache sharedCache] addTile:tile WithImage:self];
	
	return self;
}
	 
-(void) tileRemovedFromScreen: (NSNotification*) notification
{
	[self cancelLoading];
}

-(id) init
{
	[NSException raise:@"Invalid initialiser" format:@"Use the designated initialiser for TileImage"];
	[self release];
	return nil; 
}

+ (TileImage*) dummyTile: (Tile)tile
{
	return [[[TileImage alloc] initBlankTile:tile] autorelease];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

//	if (image)
//		CGImageRelease(image);

	[image release];
	
	[super dealloc];
}
/*
- (id) increaseLoadingPriority
{
	loadingPriorityCount++;
	return self;
}
- (id) decreaseLoadingPriority
{
	loadingPriorityCount--;
	if (loadingPriorityCount == 0)
		[self cancelLoading];
	return self;
}*/

- (void)drawInRect:(CGRect)rect
{
	[image drawInRect:rect];
/*	if (image != NULL)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();

		NSLog(@"image width = %f", CGImageGetWidth(image));
		//		CGContextClipToRect(context, rect);
		CGContextDrawImage(context, rect, image);
	}*/
}

-(void)draw
{
	[self drawInRect:screenLocation];
}

+ (TileImage*)imageWithTile: (Tile) _tile FromURL: (NSString*)url
{
	return [[[WebTileImage alloc] initWithTile:_tile FromURL:url] autorelease];
}

+ (TileImage*)imageWithTile: (Tile) _tile FromFile: (NSString*)filename
{
	return [[[FileTileImage alloc] initWithTile: _tile FromFile:filename] autorelease];
}

-(void) cancelLoading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageLoadingCancelledNotification
														object:self];
}
//
//- (void)setImageToData: (NSData*) data
//{
//	image = [[UIImage imageWithData:data] retain];
//}

- (void)setImageToData: (NSData*) data
{
//	CGContextRef context = 
	CGImageRef cgImage = CGImageCreateWithPNGDataProvider(CGDataProviderCreateWithCFData ((CFDataRef)data), NULL, FALSE, kCGRenderingIntentDefault);
//	CGImageRetain(image);
	
	if (layer == nil)
	{
		image = [[UIImage imageWithCGImage:cgImage] retain];
	}
	else
	{
		NSLog(@"Replacing image contents with data");
		layer.contents = (id)cgImage;
	}
	
	NSDictionary *d = [NSDictionary dictionaryWithObject:data forKey:@"data"];
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageLoadedNotification
														object:self
													  userInfo:d];
}

- (NSUInteger)hash
{
	return (NSUInteger)TileHash(tile);
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[TileImage class]])
		return NO;

	return TilesEqual(tile, [(TileImage*)anObject tile]);
}

- (void)makeLayer
{
	if (layer == nil)
	{
		layer = [[CALayer alloc] init];
		layer.contents = nil;
		layer.anchorPoint = CGPointMake(0.0f, 0.0f);
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
		layer.position = screenLocation.origin;
	}
	
	if (image != nil)
	{
		layer.contents = (id)[image CGImage];
		[image release];
		image = nil;
	}
}

- (void)moveBy: (CGSize) delta
{
	self.screenLocation = TranslateCGRectBy(screenLocation, delta);
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	self.screenLocation = ScaleCGRectAboutPoint(screenLocation, zoomFactor, center);
}

- (CGRect) screenLocation
{
	return screenLocation;
}

- (void) setScreenLocation: (CGRect)newScreenLocation
{
//	NSLog(@"location moving from %f %f to %f %f", screenLocation.origin.x, screenLocation.origin.y, newScreenLocation.origin.x, newScreenLocation.origin.y);
	screenLocation = newScreenLocation;
	
	if (layer != nil)
	{
		//		layer.frame = screenLocation;
		layer.position = screenLocation.origin;
		layer.bounds = CGRectMake(0, 0, screenLocation.size.width, screenLocation.size.height);
	}
}

@end
