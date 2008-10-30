//
//  ScreenProjection.h
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMFoundation.h"

// This is a stateful projection. As the screen moves around, so too do projections change.

@interface RMMercatorToScreenProjection : NSObject
{
	// What the screen is currently looking at.
	RMXYPoint origin;
	
	// Bounds of the screen in pixels
	CGRect screenBounds;

	// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	// Scale of 1 means 1 pixel == 1 meter.
	// Scale of 10 means 1 pixel == 10 meters.
	float scale;
}

- (id) initWithScreenBounds: (CGRect)aScreenBounds;

// Deltas in screen coordinates.
- (RMXYPoint)movePoint: (RMXYPoint)aPoint by:(CGSize) delta;
- (RMXYRect)moveRect: (RMXYRect)aRect by:(CGSize) delta;

// pivot given in screen coordinates.
- (RMXYPoint)zoomPoint: (RMXYPoint)aPoint byFactor: (float)factor near:(CGPoint) pivot;
- (RMXYRect)zoomRect: (RMXYRect)aRect byFactor: (float)factor near:(CGPoint) pivot;

// Move the screen.
- (void) moveScreenBy: (CGSize) delta;
- (void) zoomScreenByFactor: (float) factor near:(CGPoint) aPoint;

// Project -> screen coordinates.

- (CGPoint) projectXYPoint: (RMXYPoint) aPoint;
- (CGRect) projectXYRect: (RMXYRect) aRect;

- (RMXYPoint) projectScreenPointToXY: (CGPoint) aPoint;
- (RMXYRect) projectScreenRectToXY: (CGRect) aRect;
- (RMXYSize)projectScreenSizeToXY: (CGSize) aSize;

- (RMXYRect) XYBounds;
- (void) setXYBounds: (RMXYRect) bounds;
- (RMXYPoint) XYCenter;
- (void) setXYCenter: (RMXYPoint) aPoint;
- (CGRect) screenBounds;

@property (assign, readwrite) float scale;


@end
