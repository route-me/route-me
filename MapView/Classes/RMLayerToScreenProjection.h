//
//  LayerToScreenProjection.h
//  RouteMe
//
//  Created by Joseph Gentle on 11/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMScreenProjection.h"

@class CALayer;

// This is a nasty little class which pretends to be a regular screenprojection
// in order to 
@interface RMLayerToScreenProjection : RMScreenProjection {
	CALayer *layer;
}

-(id) initWithBounds: (CGRect) bounds InLayer: (CALayer *)layer;

@end
