//
//  TileImageCache.h
//  Images
//
//  Created by Joseph Gentle on 30/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import "RMTileSource.h"

@class RMTileImage;

typedef enum {
	RMCachePurgeStrategyLRU,
	RMCachePurgeStrategyFIFO,
} RMCachePurgeStrategy;


@protocol RMTileCache<NSObject>

// Returns the cached image if it exists. nil otherwise.
-(RMTileImage*) cachedImage:(RMTile)tile;
-(void)didReceiveMemoryWarning;

@optional

-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image;

@end


@interface RMTileCache : NSObject<RMTileCache>
{
	NSMutableArray *caches;
}

-(id)initWithTileSource: (id<RMTileSource>) tileSource;

+(NSNumber*) tileHash: (RMTile)tile;

// Add tile to cache
-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image;

// Add another cache to the chain
-(void)addCache: (id<RMTileCache>)cache;

-(void)didReceiveMemoryWarning;

@end
