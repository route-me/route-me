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
//#include <Quartz/Quartz.h>
#include <stdint.h>

typedef struct{
	uint32_t x, y;
	short zoom;
} RMTile;

typedef struct{
	RMTile tile;
	CGPoint offset;
} RMTilePoint;

typedef struct{
	RMTilePoint origin;
	CGSize size;
} RMTileRect;

char RMTilesEqual(RMTile one, RMTile two);

char RMTileIsDummy(RMTile tile);
RMTile RMTileDummy();
// Return a hash of the tile
uint64_t RMTileHash(RMTile tile);

// Round the rectangle to whole numbers of tiles
RMTileRect RMTileRectRound(RMTileRect rect);
/*
// Calculate and return the intersection of two rectangles
TileRect TileRectIntersection(TileRect one, TileRect two);

// Calculate and return the union of two rectangles
TileRect TileRectUnion(TileRect one, TileRect two);
*/
#endif