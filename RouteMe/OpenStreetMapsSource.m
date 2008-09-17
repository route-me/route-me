//
//  OpenStreetMapsSource.m
//  Images
//
//  Created by Joseph Gentle on 19/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OpenStreetMapsSource.h"
#import "Projection.h"
#import "Transform.h"
#import "TileImage.h"
#import "TileLoader.h"
#import "FractalTileProjection.h"
#import "TiledLayerController.h"

@implementation OpenStreetMapsSource

-(id) init
{
	if (![super init])
		return nil;
	
//	trans = [[Transform alloc] initFrom:latlong To:google];
	
	baseURL = @"http://a.tile.openstreetmap.org/";
	
	MercatorRect bounds;
	bounds.origin.x = -20037508.34;
	bounds.origin.y = -20037508.34;
	bounds.size.width = 20037508.34 * 2;
	bounds.size.height = 20037508.34 * 2;
	tileProjection = [[FractalTileProjection alloc] initWithBounds:bounds TileSideLength:256 MaxZoom:18];
	
	return self;
}

-(void) dealloc
{
	[tileProjection release];
	[super dealloc];
}

-(NSString*) tileURL: (Tile) tile
{
	return [NSString stringWithFormat:@"http://a.tile.openstreetmap.org/%d/%d/%d.png", tile.zoom, tile.x, tile.y];
}

-(TileImage *) tileImage: (Tile)tile
{
	TileImage* image = [TileImage imageWithTile: tile FromURL:[self tileURL:tile]];
//		[cache addTile:tile WithImage:image];
	return image;
}

-(FractalTileProjection*) tileProjection
{
	return [[tileProjection retain] autorelease];
}

-(MercatorRect) bounds
{
	return [tileProjection bounds];
}

//@synthesize cache;

@end
