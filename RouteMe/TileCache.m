//
//  TileCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileCache.h"

@implementation TileCache

-(id)initWithParentSource: (id)source
{
	if (![super init])
		return nil;
	
	if ([[self class] isEqual:[TileCache class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileCache directly."];
		[self release];
		return nil; 
	}
	
	tileSource = [source retain];
	
	return self;
}

-(void) dealloc
{
	[tileSource release];
	[super dealloc];
}

+(uint64_t) rawTileHash: (Tile)tile
{
	uint64_t accumulator = 0;
	
	for (int i = 0; i < tile.zoom; i++) {
		accumulator |= ((uint64_t)tile.x & (1LL<<i)) << i;
		accumulator |= ((uint64_t)tile.y & (1LL<<i)) << (i+1);
	}
	accumulator |= 1LL<<(tile.zoom * 2);
	
	return accumulator;
}

+(NSNumber*) tileHash: (Tile)tile
{
	return [NSNumber numberWithUnsignedLongLong:[TileCache rawTileHash: tile]];
}

// Returns the cached image if it exists. nil otherwise.
-(TileImage*) cachedImage:(Tile)tile
{
	return nil;
}

// Add tile to cache
-(void)addTile: (Tile)tile WithImage: (TileImage*)image { }

-(FractalTileProjection*) tileProjection
{
	return [tileSource tileProjection];
}

@end
