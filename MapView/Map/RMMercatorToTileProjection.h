//
//  RMTileProjection.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMercator.h"
#import "RMTile.h"
#import "RMMercatorToTileProjection.h"

@class RMMercatorToScreenProjection;

// A tile projection is a projection which turns mercators into tile coordinates.

// At time of writing, read RMFractalTileProjection to see the implementation of this.

@protocol RMMercatorToTileProjection<NSObject>

-(RMTilePoint) project: (RMMercatorPoint)mercator AtZoom:(float)zoom;
-(RMTileRect) projectRect: (RMMercatorRect)mercatorRect AtZoom:(float)zoom;

-(RMTilePoint) project: (RMMercatorPoint)mercator AtScale:(float)scale;
-(RMTileRect) projectRect: (RMMercatorRect)mercatorRect AtScale:(float)scale;

// This is a helper for projectRect above. Much simpler for the caller.
-(RMTileRect) project: (RMMercatorToScreenProjection*)screen;

-(RMTile) normaliseTile: (RMTile) tile;

-(float) normaliseZoom: (float) zoom;

-(float) calculateZoomFromScale: (float) scale;
-(float) calculateNormalisedZoomFromScale: (float) scale;
-(float) calculateScaleFromZoom: (float) zoom;

// Mercator bounds of the earth.
@property(readonly, nonatomic) RMMercatorRect bounds;

// Maximum zoom for which we have tile images
@property(readonly, nonatomic) int maxZoom;

// Tile side length in pixels
@property(readonly, nonatomic) int tileSideLength;

@end
