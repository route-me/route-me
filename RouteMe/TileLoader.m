//
//  TimeImageSet.m
//  Images
//
//  Created by Joseph Gentle on 29/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileLoader.h"

#import "TileImage.h"
#import "TileSource.h"
#import "MathUtils.h"
#import "ScreenProjection.h"
#import "FractalTileProjection.h"
#import "TileImageSet.h"

NSString* const MapImageRemovedFromScreenNotification = @"MapImageRemovedFromScreen";

@implementation TileLoader

@synthesize loadedBounds, loadedZoom;
/*
-(id) initFromRect:(TileRect) rect FromImageSource: (id<TileSource>)source ToDisplayIn:(CGRect)bounds WithTileDelegate: (id)delegate
{
	if (![self init])
		return nil;
	[self assembleFromRect:rect FromImageSource: source ToDisplayIn:bounds WithTileDelegate: delegate];
	return self;
}*/

-(TileImage*) makeTileImageFor:(Tile) tile
{
	return [tileSource tileImage:tile];
}

-(id) init
{
	if (![self initForScreen:nil FromImageSource:nil])
		return nil;

	return self;
}

-(id) initForScreen: (ScreenProjection*)screen FromImageSource: (id<TileSource>)source
{
	if (![super init])
		return nil;
	
	images = [[TileImageSet alloc] initWithDelegate:self];
	loadedBounds = CGRectMake(0, 0, 0, 0);
	loadedTiles.origin.tile = TileDummy();
		
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

-(void) tileRemoved: (Tile) tile
{
	TileImage *image = [images imageWithTile:tile];
	[[NSNotificationCenter defaultCenter] postNotificationName:MapImageRemovedFromScreenNotification object:image];
}

-(void) tileAdded: (Tile) tile WithImage: (TileImage*) image
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
	
	NSLog(@"assemble count = %d", [images count]);
	
	FractalTileProjection *tileProjection = [tileSource tileProjection];
	TileRect newTileRect = [tileProjection project:screenProjection];
	
	CGRect newLoadedBounds = [images addTiles:newTileRect ToDisplayIn:[self currentRendererBounds]];
	
	if (!TileIsDummy(loadedTiles.origin.tile))
		[images removeTiles:loadedTiles];

	NSLog(@"-> count = %d", [images count]);

	loadedBounds = newLoadedBounds;
	loadedZoom = newTileRect.origin.tile.zoom;
	loadedTiles = newTileRect;
}

- (void)moveBy: (CGSize) delta
{
	[images moveBy:delta];
	loadedBounds = TranslateCGRectBy(loadedBounds, delta);
//	[self assemble];
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	[images zoomByFactor:zoomFactor Near:center];
	loadedBounds = ScaleCGRectAboutPoint(loadedBounds, zoomFactor, center);
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
