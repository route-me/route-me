//
//  FractalTileProjection.h
//  Images
//
//  Created by Joseph Gentle on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMercator.h"
#import "RMTile.h"

@class RMScreenProjection;

@interface RMFractalTileProjection : NSObject {
	// Maximum zoom for which our tile server stores images
	int maxZoom;
	
	// Mercator bounds of the earth 
	RMMercatorRect bounds;
	
	// Normally 256. This class assumes tiles are square.
	int tileSideLength;
	
	// The deal is, we have a scale which stores how many mercator gradiants per pixel
	// in the image.
	// If you run the maths, scale = bounds.width/(2^zoom * tileSideLength)
	// or if you want, z = log(bounds.width/tileSideLength) - log(s)
	// So here we'll cache the first term for efficiency.
	// I'm using width arbitrarily - I'm not sure what the effect of using the other term is when they're not the same.
	double scaleFactor;
}

@property(readonly, nonatomic) RMMercatorRect bounds;
@property(readonly, nonatomic) int maxZoom;
@property(readonly, nonatomic) int tileSideLength;

-(id) initWithBounds: (RMMercatorRect)bounds TileSideLength:(int)tileSideLength MaxZoom: (int) max_zoom;

-(RMTilePoint) project: (RMMercatorPoint)mercator AtZoom:(float)zoom;
-(RMTileRect) projectRect: (RMMercatorRect)mercatorRect AtZoom:(float)zoom;

-(RMTilePoint) project: (RMMercatorPoint)mercator AtScale:(float)scale;
-(RMTileRect) projectRect: (RMMercatorRect)mercatorRect AtScale:(float)scale;

// This is a helper for projectRect above. Much simpler for the caller.
-(RMTileRect) project: (RMScreenProjection*)screen;

-(float) normaliseZoom: (float) zoom;

-(float) calculateZoomFromScale: (float) scale;
-(float) calculateNormalisedZoomFromScale: (float) scale;
-(float) calculateScaleFromZoom: (float) zoom;

@end
