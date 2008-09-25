//
//  RMMapView.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMLatLong.h"
#import "RMMercator.h"
#import <CoreGraphics/CGGeometry.h>

@class RMMapContents;

// iPhone-specific mapview stuff.
// Handles event handling, whatnot.

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
	int numTouches;
} RMGestureDetails;


@interface RMMapView : UIView
{
	RMMapContents *contents;
	
	bool enableDragging;
	bool enableZoom;
	RMGestureDetails lastGesture;
}

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToMercator: (RMMercatorPoint)mercator;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@end
