//
//  TileCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileCache.h"

#import "RMMemoryCache.h"
#import "RMDiskCache.h"

static RMTileCache *cache = nil;

@implementation RMTileCache

-(id)init
{
	if (![super init])
		return nil;
	
	RMMemoryCache *memoryCache = [[RMMemoryCache alloc] init];
	RMDiskCache *diskCache = [[RMDiskCache alloc] init];
	
	caches = [[NSMutableArray alloc] init];
	
	[self addCache:memoryCache];
	[self addCache:diskCache];
	
	[memoryCache release];
	[diskCache release];
	
	return self;
}

-(void) dealloc
{
	[caches release];
	[super dealloc];
}

+(RMTileCache*)sharedCache
{
	if (cache == nil)
	{
		cache = [[RMTileCache alloc] init];
	}
	return cache;
}

-(void)addCache: (id<RMTileCache>)cache
{
	[caches addObject:cache];
}

+(NSNumber*) tileHash: (RMTile)tile
{
	return [NSNumber numberWithUnsignedLongLong: RMTileHash(tile)];
}

// Returns the cached image if it exists. nil otherwise.
-(RMTileImage*) cachedImage:(RMTile)tile
{
	for (id<RMTileCache> cache in caches)
	{
		RMTileImage *image = [cache cachedImage:tile];
		if (image != nil)
			return image;
	}
	
	return nil;
}

-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image
{
	for (id<RMTileCache> cache in caches)
	{	
		if ([cache respondsToSelector:@selector(addTile:WithImage:)])
		{
			[cache addTile:tile WithImage:image];
		}
	}
}

@end
