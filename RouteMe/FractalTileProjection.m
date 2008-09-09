//
//  FractalTileProjection.m
//  Images
//
//  Created by Joseph Gentle on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FractalTileProjection.h"
#import "ScreenProjection.h"
#import <math.h>

@implementation FractalTileProjection

@synthesize maxZoom, tileSideLength, bounds;

-(id) initWithBounds: (CGRect)_bounds TileSideLength:(int)_tileSideLength MaxZoom: (int)_maxZoom
{
	if (![super init])
		return nil;
	
	bounds = _bounds;
	tileSideLength = _tileSideLength;
	maxZoom = _maxZoom;
	
	scaleFactor = log2(bounds.size.width / tileSideLength);
	
	return self;
}

-(float) normaliseZoom: (float) zoom
{
	float normalised_zoom = roundf(zoom);
	//16;
	if (normalised_zoom > maxZoom)
		normalised_zoom = maxZoom;
	if (normalised_zoom < 0)
		normalised_zoom = 0;
	
	return normalised_zoom;
}

-(float) limitFromNormalisedZoom: (float) zoom
{
	return exp2f(zoom);
}

-(TilePoint) projectInternal: (MercatorPoint)mercator AtNormalisedZoom:(float)zoom Limit:(float) limit
{
	TilePoint tile;
	double x = (mercator.x - bounds.origin.x) / bounds.size.width * limit;
	// Unfortunately, y is indexed from the bottom left.. hence we have to translate it.
	double y = (double)limit * ((bounds.origin.y - mercator.y) / bounds.size.height + 1);
	
	tile.tile.x = (int)x;
	tile.tile.y = (int)y;
	tile.tile.zoom = zoom;
	tile.offset.x = (float)x - tile.tile.x;
	tile.offset.y = (float)y - tile.tile.y;
	
	return tile;
}

-(TilePoint) project: (MercatorPoint)mercator AtZoom:(float)zoom
{
	float normalised_zoom = [self normaliseZoom:zoom];
	float limit = [self limitFromNormalisedZoom:normalised_zoom];
	
	return [self projectInternal:mercator AtNormalisedZoom:normalised_zoom Limit:limit];
}

-(TileRect) projectRect: (MercatorRect)mercator AtZoom:(float)zoom
{
	int normalised_zoom = [self normaliseZoom:zoom];
	float limit = [self limitFromNormalisedZoom:normalised_zoom];

	TileRect rect;
	// The origin for projectInternal will have to be the top left instead of the bottom left.
	MercatorPoint topLeft = mercator.origin;
	topLeft.y += mercator.size.height;
	rect.origin = [self projectInternal:topLeft AtNormalisedZoom:normalised_zoom Limit:limit];

	rect.size.width = mercator.size.width / bounds.size.width * limit;
	rect.size.height = mercator.size.height / bounds.size.height * limit;
	
	return rect;
}

-(TilePoint) project: (MercatorPoint)mercator AtScale:(float)scale
{
	return [self project:mercator AtZoom:[self calculateZoomFromScale:scale]];
}
-(TileRect) projectRect: (MercatorRect)mercatorRect AtScale:(float)scale
{
	return [self projectRect:mercatorRect AtZoom:[self calculateZoomFromScale:scale]];
}

-(TileRect) project: (ScreenProjection*)screen;
{
	return [self projectRect:[screen mercatorBounds] AtScale:[screen scale]];
}

-(float) calculateZoomFromScale: (float) scale
{	// zoom = log2(bounds.width/tileSideLength) - log2(s)
	return scaleFactor - log2(scale);
}

-(float) calculateNormalisedZoomFromScale: (float) scale
{
	return [self normaliseZoom:[self calculateZoomFromScale:scale]];
}

-(float) calculateScaleFromZoom: (float) zoom
{
	return bounds.size.width / 256 / exp2(zoom);	
}

@end
