//
//  Tile.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileImage.h"
#import "RMWebTileImage.h"
#import "RMTileLoader.h"
#import "RMFileTileImage.h"
#import "RMTileCache.h"
#import "RMMathUtils.h"
#import <QuartzCore/QuartzCore.h>

NSString * const RMMapImageLoadedNotification = @"MapImageLoaded";
NSString * const RMMapImageLoadingCancelledNotification = @"MapImageLoadingCancelled";

@implementation RMTileImage

@synthesize tile, layer, image, lastUsedTime;

- (id) initBlankTile: (RMTile)_tile
{
	if (![super init])
		return nil;
	
	tile = _tile;
	image = nil;
	layer = nil;
	loadingPriorityCount = 0;
	lastUsedTime = nil;
	[self touch];
	
	return self;	
}

- (id) initWithTile: (RMTile)_tile
{
	if (![self initBlankTile: _tile])
		return nil;

	if ([[self class] isEqual:[RMTileImage class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileImage directly."];
		[self release];
		return nil;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tileRemovedFromScreen:)
												 name:MapImageRemovedFromScreenNotification object:self];
	
	// Should this be done as a notification?
	[[RMTileCache sharedCache] addTile:tile WithImage:self];
	
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

+ (RMTileImage*) dummyTile: (RMTile)tile
{
	return [[[RMTileImage alloc] initBlankTile:tile] autorelease];
}

- (void)dealloc
{
//	NSLog(@"Removing tile image %d %d %d", tile.x, tile.y, tile.zoom);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

//	if (image)
//		CGImageRelease(image);

	[image release];
	[layer release];
	[lastUsedTime release];
	
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

+ (RMTileImage*)imageWithTile: (RMTile) _tile FromURL: (NSString*)url
{
	return [[[RMWebTileImage alloc] initWithTile:_tile FromURL:url] autorelease];
}

+ (RMTileImage*)imageWithTile: (RMTile) _tile FromFile: (NSString*)filename
{
	return [[[RMFileTileImage alloc] initWithTile: _tile FromFile:filename] autorelease];
}

-(void) cancelLoading
{
	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadingCancelledNotification
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
	CGDataProviderRef provider = CGDataProviderCreateWithCFData ((CFDataRef)data);
	CGImageRef cgImage = CGImageCreateWithPNGDataProvider(provider, NULL, FALSE, kCGRenderingIntentDefault);
	CGDataProviderRelease(provider);
//	CGImageRetain(image);
	
	if (layer == nil)
	{
		image = [[UIImage imageWithCGImage:cgImage] retain];
	}
	else
	{
//		NSLog(@"Replacing image contents with data");
		layer.contents = (id)cgImage;
	}
	
	CGImageRelease(cgImage);
	
	NSDictionary *d = [NSDictionary dictionaryWithObject:data forKey:@"data"];
	[[NSNotificationCenter defaultCenter] postNotificationName:RMMapImageLoadedNotification
														object:self
													  userInfo:d];
}

- (NSUInteger)hash
{
	return (NSUInteger)RMTileHash(tile);
}

-(void) touch
{
	[lastUsedTime release];
	lastUsedTime = [NSDate init];
}

- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[RMTileImage class]])
		return NO;

	return RMTilesEqual(tile, [(RMTileImage*)anObject tile]);
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
	self.screenLocation = RMTranslateCGRectBy(screenLocation, delta);
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	self.screenLocation = RMScaleCGRectAboutPoint(screenLocation, zoomFactor, center);
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
	
	[self touch];
}

@end
