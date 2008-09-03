/*
 *  Tile.h
 *  Images
 *
 *  Created by Joseph Gentle on 29/08/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <CoreGraphics/CGGeometry.h>

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

