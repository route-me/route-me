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

@interface MemoryCache : NSObject <TileCache> {
	NSMutableDictionary *cache;
	
//	id tileSource;
}

-(id)initWithCapacity: (NSUInteger) capacity;

//-(id)initWithTileSource: (id)source;

@end
