/*
 *  Tile.h
 *  Images
 *
 *  Created by Joseph Gentle on 29/08/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _TILE_H_
#define _TILE_H_

#include <CoreGraphics/CGGeometry.h>
#include <stdint.h>

typedef struct{
	uint32_t x, y;
	short zoom;
} Tile;

typedef struct{
	Tile tile;
	CGPoint offset;
} TilePoint;

typedef struct{
	TilePoint origin;
	CGSize size;
} TileRect;

char TilesEqual(Tile one, Tile two);

char TileIsDummy(Tile tile);
Tile TileDummy();
// Return a hash of the tile
uint64_t TileHash(Tile tile);

// Round the rectangle to whole numbers of tiles
TileRect TileRectRound(TileRect rect);
/*
// Calculate and return the intersection of two rectangles
TileRect TileRectIntersection(TileRect one, TileRect two);

// Calculate and return the union of two rectangles
TileRect TileRectUnion(TileRect one, TileRect two);
*/
#endif