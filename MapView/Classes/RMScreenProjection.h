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

@interface RMScreenProjection : NSObject {
	RMMercatorPoint topLeft;
	
	// Bounds of the screen in pixels
	CGRect bounds;
	
	// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	// Scale of 1 means 1 pixel == 1 meter.
	// Scale of 10 means 1 pixel == 10 meters.
	float scale;
}

-(id) initWithBounds: (CGRect) bounds;

-(void) moveToMercator: (RMMercatorPoint) point;
-(void) moveToLatLong: (CLLocationCoordinate2D) point;

- (void)moveBy: (CGSize) delta;
// Center given in screen coordinates.
- (void)zoomByFactor: (float) factor Near:(CGPoint) center;
- (void)zoomBy: (float) factor;

-(CGPoint) projectMercatorPoint: (RMMercatorPoint) point;
-(CGRect) projectMercatorRect: (RMMercatorRect) rect;

-(RMMercatorPoint) projectInversePoint: (CGPoint) point;
-(RMMercatorRect) projectInverseRect: (CGRect) rect;

-(RMMercatorRect) mercatorBounds;
-(CGRect) screenBounds;

@property (assign, readwrite) float scale;
@property (readonly) RMMercatorPoint topLeft;

//@property (assign, readwrite) CGSize viewSize;


@end
