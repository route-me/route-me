//
//  ScreenProjection.h
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mercator.h"
#import <CoreLocation/CoreLocation.h>

@interface ScreenProjection : NSObject {
	MercatorPoint topLeft;
	
	// Size in pixels
	CGSize viewSize;
	
	// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	// Scale of 1 means 1 pixel == 1 meter.
	// Scale of 10 means 1 pixel == 10 meters.
	double scale;
}

-(id) initWithSize: (CGSize) size;
-(void) centerMercator: (MercatorPoint) point;
-(void) centerLatLong: (CLLocationCoordinate2D) point;
-(void) dragBy: (CGSize) delta;
-(void) zoomByFactor: (double) zoomFactor Near:(CGPoint) center;

-(CGPoint) projectMercatorPoint: (MercatorPoint) point;
-(CGRect) projectMercatorRect: (MercatorRect) rect;

-(MercatorPoint) projectInversePoint: (CGPoint) point;
-(MercatorRect) projectInverseRect: (CGRect) rect;

-(MercatorRect) bounds;

@property (assign, readwrite) double scale;
@property (assign, readwrite) CGSize viewSize;


@end
