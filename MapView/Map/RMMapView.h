//
//  RMMapView.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMMapViewDelegate.h"
#import "RMMapContents.h"

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
@interface RMMapView : UIView <RMMapContentsFacade, RMMapContentsAnimationCallback>
{
	RMMapContents *contents;
	id<RMMapViewDelegate> delegate;
	BOOL enableDragging;
	BOOL enableZoom;
	RMGestureDetails lastGesture;
	float decelerationFactor;
	BOOL deceleration;
}

// Any other functions you need to manipulate the mapyou can access through this
// property. The contents structure holds the actual map bits.
@property (readonly) RMMapContents *contents;

@property (retain, readonly) RMMarkerManager *markerManager;

// do not retain the delegate so you can let the corresponding controller implement the
// delegate without circular references
@property (assign) id<RMMapViewDelegate> delegate;
@property (readwrite) float decelerationFactor;
@property (readwrite) BOOL deceleration;


- (id)initWithFrame:(CGRect)frame WithLocation:(CLLocationCoordinate2D)latlong;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToXYPoint: (RMXYPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint animated:(BOOL)animated;

- (void)didReceiveMemoryWarning;

@end
