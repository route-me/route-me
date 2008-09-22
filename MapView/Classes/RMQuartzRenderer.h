//
//  QuartzRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapRenderer.h"

@class RMTileLoader;

@interface RMQuartzRenderer : RMMapRenderer {	
	RMTileLoader *tileLoader;
}

@end
