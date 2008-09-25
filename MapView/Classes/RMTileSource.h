//
//  TileSource.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTile.h"
#import "RMMercator.h"

@class RMTileImage;
@class RMFractalTileProjection;
@class RMTileLoader;
@class RMTiledLayerController;
@class RMTileCache;
@protocol RMMercatorToTileProjection;
@class RMLatLongToMercatorProjection;

@protocol RMTileSource <NSObject>

-(RMTileImage *) tileImage: (RMTile) tile;
-(id<RMMercatorToTileProjection>) mercatorToTileProjection;
-(RMLatLongToMercatorProjection*) latLongToMercatorProjection;

-(RMMercatorRect) bounds;

//
//@optional
//
//-(void) setCache: (TileCache*)cache;

@end
