//
//  RMMapView.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

#import "RMLatLong.h"
#import "RMMercator.h"

// iPhone-specific mapview stuff.
// Handles event handling, whatnot.

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
	int numTouches;
} RMGestureDetails;


@class RMMapContents;

// This class is a wrapper around RMMapContents for the iphone.
// It implements event handling; but thats about it. All the interesting map
// logic is done by RMMapContents.
@interface RMMapView : UIView
{
	RMMapContents *contents;
	
	bool enableDragging;
	bool enableZoom;
	RMGestureDetails lastGesture;
}

// Any other functions you need to manipulate the mapyou can access through this
// property. The contents structure holds the actual map bits.
@property (readonly) RMMapContents *contents;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToMercator: (RMMercatorPoint)mercator;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@end
