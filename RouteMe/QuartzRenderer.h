//
//  QuartzRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapRenderer.h"

@class ScreenProjection;
@class MapView;
@class TileImageSet;

@interface QuartzRenderer : MapRenderer {	
	// This is basically a one-object allocation pool.
	TileImageSet *imageSet;
}

@end
