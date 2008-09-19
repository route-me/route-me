//
//  OpenStreetMapsSource.m
//  Images
//
//  Created by Joseph Gentle on 19/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMOpenStreetMapsSource.h"
#import "RMProjection.h"
#import "RMTransform.h"
#import "RMTileImage.h"
#import "RMTileLoader.h"
#import "RMFractalTileProjection.h"
#import "RMTiledLayerController.h"

@implementation RMOpenStreetMapsSource

-(id) init
{
	if (![super init])
		return nil;
	
//	trans = [[Transform alloc] initFrom:latlong To:google];
	
	baseURL = @"http://a.tile.openstreetmap.org/";
	
	RMMercatorRect bounds;
	bounds.origin.x = -20037508.34;
	bounds.origin.y = -20037508.34;
	bounds.size.width = 20037508.34 * 2;
	bounds.size.height = 20037508.34 * 2;
	tileProjection = [[RMFractalTileProjection alloc] initWithBounds:bounds TileSideLength:256 MaxZoom:18];
	
	return self;
}

-(void) dealloc
{
	[tileProjection release];
	[super dealloc];
}

-(NSString*) tileURL: (RMTile) tile
{
	return [NSString stringWithFormat:@"http://tile.openstreetmap.org/%d/%d/%d.png", tile.zoom, tile.x, tile.y];
}

-(RMTileImage *) tileImage: (RMTile)tile
{
	RMTileImage* image = [RMTileImage imageWithTile: tile FromURL:[self tileURL:tile]];
//		[cache addTile:tile WithImage:image];
	return image;
}

-(RMFractalTileProjection*) tileProjection
{
	return [[tileProjection retain] autorelease];
}

-(RMMercatorRect) bounds
{
	return [tileProjection bounds];
}

//@synthesize cache;

@end
