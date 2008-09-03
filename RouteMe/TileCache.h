//
//  TileImageCache.h
//  Images
//
//  Created by Joseph Gentle on 30/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tile.h"
#import "TileSource.h"

@class TileImage;
@interface TileCache : NSObject <TileSource>
{
	
	id tileSource;
}

-(id)initWithParentSource: (id)source;

+(uint64_t) rawTileHash: (Tile)tile;
+(NSNumber*) tileHash: (Tile)tile;

// Returns the cached image if it exists. nil otherwise.
-(TileImage*) cachedImage:(Tile)tile;
// Add tile to cache
-(void)addTile: (Tile)tile WithImage: (TileImage*)image;

@end