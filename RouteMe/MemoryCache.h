//
//  MemoryCache.h
//  Images
//
//  Created by Joseph Gentle on 30/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"
#import "TileCache.h"
@class TileImage;

@interface MemoryCache : TileCache {
	NSMutableDictionary *cache;

	int capacity;
}

//-(id)initWithCapacity: (NSUInteger) capacity;

-(id)initWithParentSource: (id)source Capacity: (int) capacity;

@end
