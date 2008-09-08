//
//  TileSource.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Tile.h"

@class TileImage;
@class FractalTileProjection;
@class TileImageSet;
@class TiledLayerController;
@class TileCache;

@protocol TileSource
	
-(TileImage *) tileImage: (Tile) tile;
-(FractalTileProjection*) tileProjection;

@optional

-(void) setCache: (TileCache*)cache;

@end
