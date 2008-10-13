//
//  RMLayerSet.h
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RMMercator.h"
#import "RMMapLayer.h"

@class RMMapRenderer;

@interface RMLayerSet : NSObject
{
	NSMutableArray *layers;
	
	CALayer *container;
}

- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
- (void)removeSublayer:(RMMapLayer*) layer;

- (void)moveToMercator: (RMMercatorPoint)mercator;
- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) drawRect: (CGRect)rect;
-(CALayer*) layer;

@end
