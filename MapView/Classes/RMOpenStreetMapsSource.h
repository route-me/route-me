//
//  OpenStreetMapsSource.h
//  Images
//
//  Created by Joseph Gentle on 19/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileSource.h"
#import "RMTile.h"

@class RMTileImage;
@class RMFractalTileProjection;

@interface RMOpenStreetMapsSource : NSObject <RMTileSource> {
	NSString *baseURL;
	RMFractalTileProjection *tileProjection;
}

-(RMTileImage *) tileImage: (RMTile)tile;

//-(TileImageSet*) tileImagesForScreen: (ScreenProjection*) screen;

//@property (readwrite, retain) TileCache *cache;
//@property (readonly) FractalTileProjection *tileProjection;

@end
