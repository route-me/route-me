//
//  FractalTileProjection.h
//  Images
//
//  Created by Joseph Gentle on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mercator.h"
#import "Tile.h"

@class ScreenProjection;

@interface FractalTileProjection : NSObject {
	// Maximum zoom for which our tile server stores images
	int maxZoom;
	
	// Mercator bounds of the earth 
	CGRect bounds;
	
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

@property(readonly, nonatomic) CGRect bounds;
@property(readonly, nonatomic) int maxZoom;
@property(readonly, nonatomic) int tileSideLength;

-(id) initWithBounds: (CGRect)bounds TileSideLength:(int)tileSideLength MaxZoom: (int) max_zoom;

-(TilePoint) project: (MercatorPoint)mercator AtZoom:(float)zoom;
-(TileRect) projectRect: (MercatorRect)mercatorRect AtZoom:(float)zoom;

-(TilePoint) project: (MercatorPoint)mercator AtScale:(float)scale;
-(TileRect) projectRect: (MercatorRect)mercatorRect AtScale:(float)scale;

// This is a helper for projectRect above. Much simpler for the caller.
-(TileRect) project: (ScreenProjection*)screen;

-(int) normaliseZoom: (float) zoom;

-(float) calculateZoomFromScale: (float) scale;
-(int) calculateNormalisedZoomFromScale: (float) scale;
-(float) calculateScaleFromZoom: (float) zoom;

@end
