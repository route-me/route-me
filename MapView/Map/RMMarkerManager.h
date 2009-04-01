//
//  RMMarkerManager.h
//
// Copyright (c) 2008, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

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
/// \deprecated to be renamed screenCoordinates after 0.5
- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker;
/// \deprecated to be renamed after 0.5
- (CLLocationCoordinate2D) getMarkerCoordinate2D: (RMMarker *) marker;
/// \deprecated to be renamed markersForScreenBounds after 0.5
- (NSArray *) getMarkersForScreenBounds;
- (BOOL) isMarkerWithinScreenBounds:(RMMarker*)marker;
- (BOOL) isMarker:(RMMarker*)marker withinBounds:(CGRect)rect;
- (BOOL) managingMarker:(RMMarker*)marker;
- (void) moveMarker:(RMMarker *)marker AtLatLon:(RMLatLong)point;
- (void) moveMarker:(RMMarker *)marker AtXY:(CGPoint)point;


@end
