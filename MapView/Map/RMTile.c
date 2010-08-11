//
//  RMTile.c
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include "RMTile.h"
#import <math.h>
#import <stdio.h>

uint64_t RMTileHash(RMTile tile)
{
	uint64_t accumulator = 0;
	
	for (int i = 0; i < tile.zoom; i++) {
		accumulator |= ((uint64_t)tile.x & (1LL<<i)) << i;
		accumulator |= ((uint64_t)tile.y & (1LL<<i)) << (i+1);
	}
	accumulator |= 1LL<<(tile.zoom * 2);
	
	return accumulator;
}

uint64_t RMTileKey(RMTile tile)
{
        uint64_t zoom = (uint64_t) tile.zoom & 0xFFLL; // 8bits, 256 levels
        uint64_t x = (uint64_t) tile.x & 0xFFFFFFFLL;  // 28 bits
        uint64_t y = (uint64_t) tile.y & 0xFFFFFFFLL;  // 28 bits

	uint64_t key = (zoom << 56) | (x << 28) | (y << 0);

	return key;
}

RMTile RMTileDummy()
{
	RMTile t;
	t.x = -1;
	t.y = -1;
	t.zoom = -1;
	return t;
}

char RMTileIsDummy(RMTile tile)
{
	return tile.x == -1 && tile.y == -1 && tile.zoom == -1;
}

char RMTilesEqual(RMTile one, RMTile two)
{
	return (one.x == two.x) && (one.y == two.y) && (one.zoom == two.zoom);
}

// Round the rectangle to whole numbers of tiles
RMTileRect RMTileRectRound(RMTileRect rect)
{
	rect.size.width = ceilf(rect.size.width + rect.origin.offset.x);
	rect.size.height = ceilf(rect.size.height + rect.origin.offset.y);
	rect.origin.offset = CGPointZero;
	
	return rect;
}

/*
// Calculate and return the intersection of two rectangles
TileRect TileRectIntersection(TileRect one, TileRect two)
{
	TileRect intersection;
//	NSCAssert (one.origin.tile.zoom != two.origin.tile.zoom, @"Intersecting tiles do not have matching zoom");
	intersection.origin.tile.x = maxi(one.origin.tile.x, two.origin.tile.x);
	intersection.origin.tile.y = maxi(one.origin.tile.y, two.origin.tile.y);
	
	
	
	return intersection;
}

// Calculate and return the union of two rectangles
TileRect TileRectUnion(TileRect one, TileRect two);*/
