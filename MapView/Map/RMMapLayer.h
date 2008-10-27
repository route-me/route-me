//
//  Layer.h
//  MapView
//
//  Created by Joseph Gentle on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface RMMapLayer : CALayer
{
}

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@end

#import "RMMercator.h"
@protocol RMMovingMapLayer

@property (assign, nonatomic) RMMercatorPoint location;

@end
