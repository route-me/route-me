//
//  TimeImageSet.m
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileLoader.h"

#import "RMTileImage.h"
#import "RMTileSource.h"
#import "RMMathUtils.h"
#import "RMScreenProjection.h"
#import "RMFractalTileProjection.h"
#import "RMTileImageSet.h"

#import "RMTileCache.h"

NSString* const MapImageRemovedFromScreenNotification = @"MapImageRemovedFromScreen";

@implementation RMTileLoader

@synthesize loadedBounds, loadedZoom;
/*
-(id) initFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate
{
	if (![self init])
		return nil;
	[self assembleFromRect:rect FromImageSource: source ToDisplayIn:bounds WithTileDelegate: delegate];
	return self;
}*/

-(RMTileImage*) makeTileImageFor:(RMTile) tile
{
	RMTileImage *cachedImage = [[RMTileCache sharedCache] cachedImage:tile];
	if (cachedImage != nil)
	{
		return cachedImage;
	}
	else
	{
		return [tileSource tileImage:tile];
	}
}

-(id) init
{
	if (![self initForScreen:nil FromImageSource:nil])
		return nil;

	return self;
}

-(id) initForScreen: (RMScreenProjection*)screen FromImageSource: (id<RMTileSource>)source
{
	if (![super init])
		return nil;
	
	images = [[RMTileImageSet alloc] initWithDelegate:self];
	[self clearLoadedBounds];
	loadedTiles.origin.tile = RMTileDummy();
		
	screenProjection = [screen retain];
	tileSource = [source retain];

	return self;
}

-(void) dealloc
{
	NSLog(@"Imageset dealloced");
	[images release];
//	[buffer release];
	[screenProjection release];
	[tileSource release];
	[super dealloc];
}
/*
-(void) swapBuffers
{
	NSMutableSet *temp = images;
	images = buffer;
	buffer = temp;
}*/

-(void) clearLoadedBounds
{
	loadedBounds = CGRectMake(0, 0, 0, 0);
}
-(BOOL) screenIsLoaded
{
//	return CGRectContainsRect(loadedBounds, [screenProjection screenBounds])
//		&& loadedZoom == [[tileSource tileProjection] calculateNormalisedZoomFromScale:[screenProjection scale]];

	BOOL contained = CGRectContainsRect(loadedBounds, [screenProjection screenBounds]);
	
	float targetZoom = [[tileSource tileProjection] calculateNormalisedZoomFromScale:[screenProjection scale]];
//		&& loadedZoom == ;

	if (contained == NO)
	{
		NSLog(@"reassembling because its not contained");
	}
	
	if (targetZoom != loadedZoom)
	{
		NSLog(@"reassembling because target zoom = %f, loaded zoom = %d", targetZoom, loadedZoom);
	}
	
	return contained && targetZoom == loadedZoom;
}

-(void) tileRemoved: (RMTile) tile
{
	RMTileImage *image = [images imageWithTile:tile];
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageRemovedFromScreenNotification object:image];
}

-(void) tileAdded: (RMTile) tile WithImage: (RMTileImage*) image
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageRemovedFromScreenNotification object:[NSValue valueWithBytes:&tile objCType:@encode(Tile)]];	
}

-(CGRect) currentRendererBounds
{
	return [screenProjection screenBounds];
}

-(void) assemble
{
	if ([self screenIsLoaded])
		return;
	
	if (tileSource == nil || screenProjection == nil)
		return;
	
//	NSLog(@"assemble count = %d", [images count]);
	
	RMFractalTileProjection *tileProjection = [tileSource tileProjection];
	RMTileRect newTileRect = [tileProjection project:screenProjection];
	
	CGRect newLoadedBounds = [images addTiles:newTileRect ToDisplayIn:[self currentRendererBounds]];
	
	if (!RMTileIsDummy(loadedTiles.origin.tile))
		[images removeTiles:loadedTiles];

//	NSLog(@"-> count = %d", [images count]);

	loadedBounds = newLoadedBounds;
	loadedZoom = newTileRect.origin.tile.zoom;
	loadedTiles = newTileRect;
}

- (void)moveBy: (CGSize) delta
{
	[images moveBy:delta];
	loadedBounds = RMTranslateCGRectBy(loadedBounds, delta);
//	[self assemble];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[images zoomByFactor:zoomFactor Near:center];
	loadedBounds = RMScaleCGRectAboutPoint(loadedBounds, zoomFactor, center);
//	[self assemble];
}

-(BOOL) containsRect: (CGRect)bounds
{
	return CGRectContainsRect(loadedBounds, bounds);
}

-(void) draw
{
//	[self assemble];

	[images draw];
}

@end
