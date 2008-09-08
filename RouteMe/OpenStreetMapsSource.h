//
//  OpenStreetMapsSource.h
//  Images
//
//  Created by Joseph Gentle on 19/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TileSource.h"
#import "Tile.h"

@class TileImage;
@class TileImageSet;
@class FractalTileProjection;
@class TiledLayerController;
@class TileCache;

@interface OpenStreetMapsSource : NSObject <TileSource> {

	NSString *baseURL;
	
	FractalTileProjection *tileProjection;
	
	TileCache *cache;
}

-(TileImage *) tileImage: (Tile)tile;

//-(TileImageSet*) tileImagesForScreen: (ScreenProjection*) screen;

@property (readwrite, retain) TileCache *cache;
//@property (readonly) FractalTileProjection *tileProjection;

@end
