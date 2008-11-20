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
@interface RMMapView : UIView
{
	RMMapContents *contents;
	id<RMMapViewDelegate> delegate;
	
	BOOL enableDragging;
	BOOL enableZoom;
	RMGestureDetails lastGesture;
}

// Any other functions you need to manipulate the mapyou can access through this
// property. The contents structure holds the actual map bits.
@property (readonly) RMMapContents *contents;

@property (retain, readonly) RMMarkerManager *markerManager;

// do not retain the delegate so you can let the corresponding controller implement the
// delegate without circular references
@property (assign) id<RMMapViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame WithLocation:(CLLocationCoordinate2D)latlong;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToXYPoint: (RMXYPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (void)setZoom:(int)zoomInt;
- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)setZoomBounds:(float)aMinZoom maxZoom:(float)aMaxZoom;


- (RMLatLongBounds) getScreenCoordinateBounds;


@end
