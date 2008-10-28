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

#import "RMConfiguration.h"

static RMTileCache *cache = nil;

@implementation RMTileCache

-(id)init
{
	if (![super init])
		return nil;
	
	caches = [[NSMutableArray alloc] init];

	id cacheCfg = [[RMConfiguration configuration] cacheConfiguration];
	
	if (cacheCfg==nil)
	{
		cacheCfg = [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObject: @"memory-cache" forKey: @"type"],
			[NSDictionary dictionaryWithObject: @"disk-cache"   forKey: @"type"],
			[NSDictionary dictionaryWithObject: @"db-cache"     forKey: @"type"],
			nil
		];
	}

	for (id cfg in cacheCfg) 
	{
		RMTileCache* newCache = nil;
				
		@try {
			NSString* type = [cfg valueForKey:@"type"];
			
			if ([@"memory-cache" isEqualToString: type]) 
			{
				NSNumber* capacity = [cfg objectForKey:@"capacity"];
				if (capacity == nil) capacity = [NSNumber numberWithInt: 32];
				newCache = [[RMMemoryCache alloc] initWithCapacity: [capacity intValue]];
			}
			
			if ([@"disk-cache" isEqualToString: type]) 
			{
				NSLog(@"creating disk cache");
				newCache = [[RMDiskCache alloc] init];
			}
			
			if ([@"db-cache" isEqualToString: type]) 
			{
				newCache = [[RMDatabaseCache alloc] init];
			}

			if (newCache)
			{
				[caches addObject: newCache];
				[newCache release];
			}
			else
			{
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
