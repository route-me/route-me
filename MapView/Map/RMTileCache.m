//
//  TileCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileCache.h"

#import "RMMemoryCache.h"
#import "RMDatabaseCache.h"

#import "RMConfiguration.h"

#import "RMTileSource.h"


@interface RMTileCache ( Configuration ) 

- (id<RMTileCache>) newMemoryCacheWithConfig: (NSDictionary*) cfg;
- (id<RMTileCache>) newDatabaseCacheWithConfig: (NSDictionary*) cfg tileSource: (id<RMTileSource>) tileSource;

@end


@implementation RMTileCache

-(id)initWithTileSource: (id<RMTileSource>) tileSource
{
	if (![super init])
		return nil;
	
	caches = [[NSMutableArray alloc] init];

	id cacheCfg = [[RMConfiguration configuration] cacheConfiguration];
	
	if (cacheCfg==nil)
	{
		cacheCfg = [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObject: @"memory-cache" forKey: @"type"],
			[NSDictionary dictionaryWithObject: @"db-cache"     forKey: @"type"],
			nil
		];
	}

	for (id cfg in cacheCfg) 
	{
		id<RMTileCache> newCache = nil;
				
		@try {
			NSString* type = [cfg valueForKey:@"type"];
			
			if ([@"memory-cache" isEqualToString: type]) 
				newCache = [self newMemoryCacheWithConfig: cfg];

			if ([@"db-cache" isEqualToString: type]) 
				newCache = [self newDatabaseCacheWithConfig: cfg tileSource: tileSource];				

			if (newCache) {
				[caches addObject: newCache];
				[newCache release];
			} else {
				NSLog(@"failed to create cache of type %@", type);
			}
		}
		@catch (NSException * e) {
			NSLog(@"*** configuration error: %@", [e reason]);
		}
				
	}
	return self;
}

-(void) dealloc
{
	[caches release];
	[super dealloc];
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

@implementation RMTileCache ( Configuration )

- (id<RMTileCache>) newMemoryCacheWithConfig: (NSDictionary*) cfg
{
	NSNumber* capacity = [cfg objectForKey:@"capacity"];
	if (capacity == nil) capacity = [NSNumber numberWithInt: 32];
	return [[RMMemoryCache alloc] initWithCapacity: [capacity intValue]];	
}

- (id<RMTileCache>) newDatabaseCacheWithConfig: (NSDictionary*) cfg tileSource: (id<RMTileSource>) theTileSource
{
	BOOL useCacheDir = NO;
	RMCachePurgeStrategy strategy = RMCachePurgeStrategyFIFO;				
	NSUInteger capacity = 1000;
	NSUInteger minimalPurge = capacity / 10;
	
	NSNumber* capacityNumber = [cfg objectForKey:@"capacity"];
	if (capacityNumber!=nil) {
		NSInteger value = [capacityNumber intValue];
		
		// 0 is valid: it means no capacity limit
		if (value >= 0) {
			capacity =  value;
			minimalPurge = MIN(1,capacity / 10);
		} else 
			NSLog(@"illegal value for capacity: %d", value);
	}
	
	NSString* strategyStr = [cfg objectForKey:@"strategy"];
	if (strategyStr != nil) {
		if ([strategyStr caseInsensitiveCompare:@"FIFO"] == NSOrderedSame) strategy = RMCachePurgeStrategyFIFO;
		if ([strategyStr caseInsensitiveCompare:@"LRU"] == NSOrderedSame) strategy = RMCachePurgeStrategyLRU;
	}
	
	NSNumber* useCacheDirNumber = [cfg objectForKey:@"useCachesDirectory"];
	if (useCacheDirNumber!=nil) useCacheDir =  [useCacheDirNumber boolValue];
	
	NSNumber* minimalPurgeNumber = [cfg objectForKey:@"minimalPurge"];
	if (minimalPurgeNumber != nil && capacity != 0) {
		NSInteger value = [minimalPurgeNumber intValue];
		if (value > 0 && value<=capacity) 
			minimalPurge = value;
		else {
			NSLog(@"minimalPurge must be at least one and at most the cache capacity");
		}
	}
	
	RMDatabaseCache* dbCache = [[RMDatabaseCache alloc] 
								initWithTileSource: theTileSource 
								usingCacheDir: useCacheDir
								];
	
	[dbCache setCapacity: capacity];
	[dbCache setPurgeStrategy: strategy];
	[dbCache setMinimalPurge: minimalPurge];
	
	return dbCache;
}

@end
