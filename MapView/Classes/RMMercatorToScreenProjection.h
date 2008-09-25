//
//  ScreenProjection.h
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMercator.h"
#import "RMLatLong.h"

// This is a stateful projection. As the screen moves around, so too do projections change.

@interface RMMercatorToScreenProjection : NSObject
{
	// What the screen is currently looking at.
	RMMercatorPoint origin;
	
	// Bounds of the screen in pixels
	CGRect screenBounds;

	// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	// Scale of 1 means 1 pixel == 1 meter.
	// Scale of 10 means 1 pixel == 10 meters.
	float scale;
}

-(id) initWithScreenBounds: (CGRect)screenBounds;

// Deltas in screen coordinates.
- (RMMercatorPoint)movePoint: (RMMercatorPoint)point By:(CGSize) delta;
- (RMMercatorRect)moveRect: (RMMercatorRect)rect By:(CGSize) delta;

// pivot given in screen coordinates.
- (RMMercatorPoint)zoomPoint: (RMMercatorPoint)point ByFactor: (float)factor Near:(CGPoint) pivot;
- (RMMercatorRect)zoomRect: (RMMercatorRect)rect ByFactor: (float)factor Near:(CGPoint) pivot;

// Move the screen.
- (void) moveScreenBy: (CGSize) delta;
- (void) zoomScreenByFactor: (float) factor Near:(CGPoint) point;

// Project -> screen coordinates.

-(CGPoint) projectMercatorPoint: (RMMercatorPoint) point;
-(CGRect) projectMercatorRect: (RMMercatorRect) rect;

-(RMMercatorPoint) projectScreenPointToMercator: (CGPoint) point;
-(RMMercatorRect) projectScreenRectToMercator: (CGRect) rect;
- (RMMercatorSize)projectScreenSizeToMercator: (CGSize) size;

-(RMMercatorRect) mercatorBounds;
-(void) setMercatorBounds: (RMMercatorRect) bounds;
-(RMMercatorPoint) mercatorCenter;
-(void) setMercatorCenter: (RMMercatorPoint) center;
-(CGRect) screenBounds;

@property (assign, readwrite) float scale;
//@property (readonly) RMMercatorPoint topLeft;

//@property (assign, readwrite) CGSize viewSize;


@end
