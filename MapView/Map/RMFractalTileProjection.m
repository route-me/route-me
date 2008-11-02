//
//  FractalTileProjection.m
//  Images
//
//  Created by Joseph Gentle on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMFractalTileProjection.h"
#import "RMMercatorToScreenProjection.h"
#import "RMProjection.h"
#import <math.h>

@implementation RMFractalTileProjection

@synthesize maxZoom, tileSideLength, bounds;

-(id) initFromProjection:(RMProjection*)projection tileSideLength:(int)aTileSideLength maxZoom: (int) aMaxZoom
{
	if (![super init])
		return nil;
	
	// We don't care about the rest of the projection... just the bounds is important.
	bounds = [projection bounds];
	
	if (bounds.size.width == 0.0f || bounds.size.height == 0.0f)
	{
		@throw [NSException exceptionWithName:@"RMUnknownBoundsException"
									   reason:@"RMFractalTileProjection was initialised with a projection with unknown bounds"
									 userInfo:nil];
	}
	
	tileSideLength = aTileSideLength;
	maxZoom = aMaxZoom;
	
	scaleFactor = log2(bounds.size.width / tileSideLength);
	
	return self;
}

- (float) normaliseZoom: (float) zoom
{
	float normalised_zoom = roundf(zoom);
	//16;
	if (normalised_zoom > maxZoom)
		normalised_zoom = maxZoom;
	if (normalised_zoom < 0)
		normalised_zoom = 0;
	
	return normalised_zoom;
}

- (float) limitFromNormalisedZoom: (float) zoom
{
	return exp2f(zoom);
}

- (RMTile) normaliseTile: (RMTile) tile
{
	// The mask contains a 1 for every valid x-coordinate bit.
	uint32_t mask = 1;
	for (int i = 0; i < tile.zoom; i++)
		mask <<= 1;
	
	mask -= 1;
	
	tile.x &= mask;
	
	// If the tile's y coordinate is off the screen
	if (tile.y & (~mask))
	{
		return RMTileDummy();
	}
	
	return tile;
}

- (RMXYPoint) constrainPointHorizontally: (RMXYPoint) aPoint
{
	while (aPoint.x < bounds.origin.x)
		aPoint.x += bounds.size.width;
	while (aPoint.x > (bounds.origin.x + bounds.size.width))
		aPoint.x -= bounds.size.width;
	
	return aPoint;
}

- (RMTilePoint) projectInternal: (RMXYPoint)aPoint normalisedZoom:(float)zoom limit:(float) limit
{
	RMTilePoint tile;
	RMXYPoint newPoint = [self constrainPointHorizontally:aPoint];
	
	double x = (newPoint.x - bounds.origin.x) / bounds.size.width * limit;
	// Unfortunately, y is indexed from the bottom left.. hence we have to translate it.
	double y = (double)limit * ((bounds.origin.y - newPoint.y) / bounds.size.height + 1);
	
	tile.tile.x = (uint32_t)x;
	tile.tile.y = (uint32_t)y;
	tile.tile.zoom = zoom;
	tile.offset.x = (float)x - tile.tile.x;
	tile.offset.y = (float)y - tile.tile.y;
	
	return tile;
}

- (RMTilePoint) project: (RMXYPoint)aPoint atZoom:(float)zoom
{
	float normalised_zoom = [self normaliseZoom:zoom];
	float limit = [self limitFromNormalisedZoom:normalised_zoom];
	
	return [self projectInternal:aPoint normalisedZoom:normalised_zoom limit:limit];
}

- (RMTileRect) projectRect: (RMXYRect)aRect atZoom:(float)zoom
{
	int normalised_zoom = [self normaliseZoom:zoom];
	float limit = [self limitFromNormalisedZoom:normalised_zoom];

	RMTileRect tileRect;
	// The origin for projectInternal will have to be the top left instead of the bottom left.
	RMXYPoint topLeft = aRect.origin;
	topLeft.y += aRect.size.height;
	tileRect.origin = [self projectInternal:topLeft normalisedZoom:normalised_zoom limit:limit];

	tileRect.size.width = aRect.size.width / bounds.size.width * limit;
	tileRect.size.height = aRect.size.height / bounds.size.height * limit;
	
	return tileRect;
}

-(RMTilePoint) project: (RMXYPoint)aPoint atScale:(float)scale
{
	return [self project:aPoint atZoom:[self calculateZoomFromScale:scale]];
}
-(RMTileRect) projectRect: (RMXYRect)aRect atScale:(float)scale
{
	return [self projectRect:aRect atZoom:[self calculateZoomFromScale:scale]];
}

-(RMTileRect) project: (RMMercatorToScreenProjection*)screen;
{
	return [self projectRect:[screen XYBounds] atScale:[screen scale]];
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
