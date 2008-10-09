//
//  RMLayerSet.h
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol RMMapLayer;

@interface RMLayerSet : NSObject
{
	NSMutableArray *layers;
}

- (void)addAbove: (id)layer;
- (void)addBelow: (id)layer;


- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) drawRect: (CGRect)rect;
-(CALayer*) layer;

@end
