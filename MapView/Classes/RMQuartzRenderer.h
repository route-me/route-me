//
//  QuartzRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapRenderer.h"

@class RMScreenProjection;
@class RMMapView;
@class RMTileLoader;

@interface RMQuartzRenderer : RMMapRenderer {	
	RMTileLoader *tileLoader;
}

@end
