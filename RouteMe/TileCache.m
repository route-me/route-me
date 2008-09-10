//
//  TileCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileCache.h"

#import "MemoryCache.h"
#import "DiskCache.h"

static TileCache *cache = nil;

@implementation TileCache

-(id)init
{
	if (![super init])
		return nil;
	
	MemoryCache *memoryCache = [[MemoryCache alloc] init];
	DiskCache *diskCache = [[DiskCache alloc] init];
	
	caches = [[NSMutableArray alloc] init];

	[caches addObject:memoryCache];
	[caches addObject:diskCache];
	
	[memoryCache release];
	[diskCache release];
	
	return self;
}

-(void) dealloc
{
	[caches release];
	[super dealloc];
}

+(TileCache*)sharedCache
{
	if (cache == nil)
	{
		cache = [[TileCache alloc] init];
	}
	return cache;
}

+(NSNumber*) tileHash: (Tile)tile
{
	return [NSNumber numberWithUnsignedLongLong: TileHash(tile)];
}

// Returns the cached image if it exists. nil otherwise.
-(TileImage*) cachedImage:(Tile)tile
{
	for (id<TileCache> cache in caches)
	{
		TileImage *image = [cache cachedImage:tile];
		if (image != nil)
			return image;
	}
	
	return nil;
}

-(void)addTile: (Tile)tile WithImage: (TileImage*)image
{
	for (id<TileCache> cache in caches)
	{	
		if ([cache respondsToSelector:@selector(addTile:WithImage:)])
		{
			[cache addTile:tile WithImage:image];
		}
	}
}

@end
