//
//  CoreAnimationRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapRenderer.h"

@class RMLayeredTileLoader;

@interface RMCoreAnimationRenderer : RMMapRenderer {
//	CALayer *layer;
	RMLayeredTileLoader *tileLoader;
}

@end
