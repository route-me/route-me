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

- (NSArray *)getMarkers;
- (void) removeMarker:(RMMarker *)marker;
- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker;
- (CLLocationCoordinate2D) getMarkerCoordinate2D: (RMMarker *) marker;
- (NSArray *) getMarkersForScreenBounds;

@end
