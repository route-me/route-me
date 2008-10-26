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
#import "RMDatabaseCache.h"

static RMTileCache *cache = nil;

@implementation RMTileCache

-(id)init
{
	if (![super init])
		return nil;
	
	caches = [[NSMutableArray alloc] init];

	RMMemoryCache *memoryCache = [[RMMemoryCache alloc] init];
	RMDiskCache *diskCache = [[RMDiskCache alloc] init];
	RMDatabaseCache *dbCache = [[RMDatabaseCache alloc] init];

	[self addCache:memoryCache];
	[self addCache:diskCache];
	[self addCache:dbCache];
	
	[memoryCache release];
	[diskCache release];
	[dbCache release];
	
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
