//
//  MemoryCache.m
//  Images
//
//  Created by Joseph Gentle on 30/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MemoryCache.h"
#import "TileImage.h"

@implementation MemoryCache
/*
-(id)initWithTileSource: (id)source
{
	if (![super init])
		return nil;
	
	cache = [[NSMutableDictionary alloc] init];
	
	tileSource = [source retain];
	
	return self;
}*/

-(id)initWithCapacity: (NSUInteger) capacity
{
	if (![super init])
		return nil;
	
	cache = [[NSMutableDictionary alloc] initWithCapacity:capacity];
	
	return self;
}

-(void) dealloc
{
	[cache release];
//	[tileSource release];
	[super dealloc];
}

+(uint64_t) tileCode: (Tile)tile
{
	uint64_t accumulator = 0;
	
	for (int i = 0; i < tile.zoom; i++) {
		accumulator |= ((uint64_t)tile.x & (1LL<<i)) << i;
		accumulator |= ((uint64_t)tile.y & (1LL<<i)) << (i+1);
	}
	accumulator |= 1LL<<(tile.zoom * 2);

//	NSLog(@"sizeof(acc) = %d", sizeof(accumulator));
	
//	NSLog(@"Tile: z:%d x:%d y:%d -> %x :: %x", tile.zoom, tile.x, tile.y, (int)((accumulator&0xffffffff00000000LL)>>32), (int)accumulator);
//	NSLog(@"%lld", accumulator);
	
	return accumulator;
}

-(TileImage*) cachedImage:(Tile)tile
{
	NSNumber *key = [NSNumber numberWithUnsignedLongLong:[MemoryCache tileCode: tile]];
	TileImage *image = [cache objectForKey:key];
	
/*	if (image == nil)
		NSLog(@"cache miss");
	else
		NSLog(@"cache hit");
*/	
	return image;
}

-(void)addTile: (Tile)tile WithImage: (TileImage*)image
{
	NSNumber *key = [NSNumber numberWithUnsignedLongLong:[MemoryCache tileCode: tile]];
	[cache setObject:image forKey:key];
}
/*
-(TileImage *) tileImage: (Tile) tile
{
	TileImage *image = [self cachedImage: tile];
	if (image != nil)
		return image;
	else
		return [tileSource tileImage:tile];
}
-(FractalTileProjection*) tileProjection
{
	return [tileSource tileProjection];
}*/


@end
