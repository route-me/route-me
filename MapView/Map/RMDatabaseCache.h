//
//  RMDatabaseCache.h
//  RouteMe
//
//  Created by Joseph Gentle on 19/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMTileCache.h"

@class RMTileCacheDAO;

@interface RMDatabaseCache : NSObject<RMTileCache> {
	RMTileCacheDAO *dao;
	RMCachePurgeStrategy purgeStrategy;
	NSUInteger capacity;
	NSUInteger minimalPurge;
}

+ (NSString*)dbPathForTileSource: (id<RMTileSource>) source usingCacheDir: (BOOL) useCacheDir;
-(id) initWithDatabase: (NSString*)path;
-(id) initWithTileSource: (id<RMTileSource>) source usingCacheDir: (BOOL) useCacheDir;

-(void) setPurgeStrategy: (RMCachePurgeStrategy) theStrategy;
-(void) setCapacity: (NSUInteger) theCapacity;
-(void) setMinimalPurge: (NSUInteger) thePurgeMinimum;

@end
