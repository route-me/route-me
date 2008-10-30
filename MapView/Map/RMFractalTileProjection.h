//
//  FractalTileProjection.h
//  Images
//
//  Created by Joseph Gentle on 27/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMercatorToTileProjection.h"

@interface RMFractalTileProjection : NSObject<RMMercatorToTileProjection> {
	// Maximum zoom for which our tile server stores images
	int maxZoom;
	
	// Mercator bounds of the earth 
	RMXYRect bounds;
	
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

-(id) initWithBounds:(RMXYRect)boundsRect tileSideLength:(int)tileSideLength maxZoom: (int) max_zoom;

@end
