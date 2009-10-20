//
//  RMTileCache.m
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
					/// \bug magic string literals
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
			
			/// \bug magic string literals
			if ([@"memory-cache" isEqualToString: type]) 
				newCache = [self newMemoryCacheWithConfig: cfg];

			if ([@"db-cache" isEqualToString: type]) 
				newCache = [self newDatabaseCacheWithConfig: cfg tileSource: tileSource];				

			if (newCache) {
				[caches addObject: newCache];
				[newCache release];
			} else {
				RMLog(@"failed to create cache of type %@", type);
			}
		}
		@catch (NSException * e) {
			RMLog(@"*** configuration error: %@", [e reason]);
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
	return [NSNumber numberWithUnsignedLongLong: RMTileKey(tile)];
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

-(void)didReceiveMemoryWarning
{
	LogMethod();		
	for (id<RMTileCache> cache in caches)
	{
		[cache didReceiveMemoryWarning];
	}
}

-(void) removeAllCachedImages
{
	for (id<RMTileCache> cache in caches)
	{
		[cache removeAllCachedImages];
	}
}
@end

@implementation RMTileCache ( Configuration )

/// \bug magic numbers and strings
- (id<RMTileCache>) newMemoryCacheWithConfig: (NSDictionary*) cfg
{
	NSNumber* capacity = [cfg objectForKey:@"capacity"];
	if (capacity == nil) capacity = [NSNumber numberWithInt: 32];
	return [[RMMemoryCache alloc] initWithCapacity: [capacity intValue]];	
}

/// \bug magic numbers and strings
- (id<RMTileCache>) newDatabaseCacheWithConfig: (NSDictionary*) cfg tileSource: (id<RMTileSource>) theTileSource
{
	BOOL useCacheDir = NO;
	RMCachePurgeStrategy strategy = RMCachePurgeStrategyFIFO;
	/// \bug magic numbers
	NSUInteger capacity = 1000;
	NSUInteger minimalPurge = capacity / 10;
	
	NSNumber* capacityNumber = [cfg objectForKey:@"capacity"];
	if (capacityNumber!=nil) {
		NSInteger value = [capacityNumber intValue];
		
		// 0 is valid: it means no capacity limit
		if (value >= 0) {
			capacity =  value;
			minimalPurge = MAX(1,capacity / 10);
		} else 
			RMLog(@"illegal value for capacity: %d", value);
	}
	
	NSString* strategyStr = [cfg objectForKey:@"strategy"];
	if (strategyStr != nil) {
		if ([strategyStr caseInsensitiveCompare:@"FIFO"] == NSOrderedSame) strategy = RMCachePurgeStrategyFIFO;
		if ([strategyStr caseInsensitiveCompare:@"LRU"] == NSOrderedSame) strategy = RMCachePurgeStrategyLRU;
	}
	
	/// \bug magic string literals
	NSNumber* useCacheDirNumber = [cfg objectForKey:@"useCachesDirectory"];
	if (useCacheDirNumber!=nil) useCacheDir =  [useCacheDirNumber boolValue];
	
	NSNumber* minimalPurgeNumber = [cfg objectForKey:@"minimalPurge"];
	if (minimalPurgeNumber != nil && capacity != 0) {
		NSUInteger value = [minimalPurgeNumber unsignedIntValue];
		if (value > 0 && value<=capacity) 
			minimalPurge = value;
		else {
			RMLog(@"minimalPurge must be at least one and at most the cache capacity");
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
