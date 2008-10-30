//
//  RMTileProjection.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMFoundation.h"
#import "RMTile.h"
#import "RMMercatorToTileProjection.h"

@class RMMercatorToScreenProjection;

// A tile projection is a projection which turns mercators into tile coordinates.

// At time of writing, read RMFractalTileProjection to see the implementation of this.

@protocol RMMercatorToTileProjection<NSObject>

-(RMTilePoint) project: (RMXYPoint)aPoint atZoom:(float)zoom;
-(RMTileRect) projectRect: (RMXYRect)aRect atZoom:(float)zoom;

-(RMTilePoint) project: (RMXYPoint)aPoint atScale:(float)scale;
-(RMTileRect) projectRect: (RMXYRect)aRect atScale:(float)scale;

// This is a helper for projectRect above. Much simpler for the caller.
-(RMTileRect) project: (RMMercatorToScreenProjection*)screen;

-(RMTile) normaliseTile: (RMTile) tile;

-(float) normaliseZoom: (float) zoom;

-(float) calculateZoomFromScale: (float) scale;
-(float) calculateNormalisedZoomFromScale: (float) scale;
-(float) calculateScaleFromZoom: (float) zoom;

// XY bounds of the earth.
@property(readonly, nonatomic) RMXYRect bounds;

// Maximum zoom for which we have tile images
@property(readonly, nonatomic) int maxZoom;

// Tile side length in pixels
@property(readonly, nonatomic) int tileSideLength;

@end
