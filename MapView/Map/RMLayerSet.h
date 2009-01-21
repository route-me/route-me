//
//  RMLayerSet.h
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMFoundation.h"
#import "RMMapLayer.h"

@class RMMapRenderer;
@class RMMapContents;

@interface RMLayerSet : RMMapLayer
{
	// This is the set of all sublayers, including those offscreen.
	// It is ordered back to front.
	NSMutableArray *set;
	
	// We need this reference so we can access the projections...
	RMMapContents *mapContents;
}

- (id)initForContents: (RMMapContents *)contents;

//- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
//- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
//- (void)removeSublayer:(RMMapLayer*) layer;

- (void)moveToXYPoint: (RMXYPoint)aPoint;
- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)removeSublayer:(CALayer *)layer;
- (void)removeSublayers:(NSArray *)layers;
- (void) correctPositionOfAllSublayers;
- (BOOL) hasSubLayer:(CALayer *)layer;

//-(void) drawRect: (CGRect)rect;
//-(CALayer*) layer;

@end
