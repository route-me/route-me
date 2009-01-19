//
//  RMMarkerManager.h
//  MapView
//
//  Created by olivier on 11/5/08.
//  Copyright 2008 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMMapContents.h"
#import "RMMarker.h"

@class RMProjection;

@interface RMMarkerManager : NSObject {
	RMMapContents *contents;
}

@property (assign, readwrite)  RMMapContents *contents;

- (id)initWithContents:(RMMapContents *)mapContents;

- (void) addMarker: (RMMarker*)marker;
- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point;
- (void) addDefaultMarkerAt: (CLLocationCoordinate2D)point;
- (void) removeMarkers;
- (void) hideAllMarkers;
- (void) unhideAllMarkers;

- (NSArray *)getMarkers;
- (void) removeMarker:(RMMarker *)marker;
- (void) removeMarkers:(NSArray *)markers;
- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker;
- (CLLocationCoordinate2D) getMarkerCoordinate2D: (RMMarker *) marker;
- (NSArray *) getMarkersForScreenBounds;
- (BOOL) isMarkerWithinScreenBounds:(RMMarker*)marker;
- (BOOL) isMarker:(RMMarker*)marker withinBounds:(CGRect)rect;
- (BOOL) managingMarker:(RMMarker*)marker;
- (void) moveMarker:(RMMarker *)marker AtLatLon:(RMLatLong)point;
- (void) moveMarker:(RMMarker *)marker AtXY:(CGPoint)point;


@end
