//
//  RMMapViewDelegate.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

@class RMMapView;
@class RMMarker;

/// Use this for notifications of map panning, zooming, and taps on the RMMapView.
@protocol RMMapViewDelegate <NSObject>

@optional

- (void) beforeMapMove: (RMMapView*) map;
- (void) afterMapMove: (RMMapView*) map ;

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;
- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;

/*
 \brief Tells the delegate that the region displayed by the map view just changed.
 \details This method is called whenever the currently displayed map region changes. 
 During scrolling and zooming, this method may be called many times to report updates to the map position. 
 Therefore, your implementation of this method should be as lightweight as possible to avoid affecting scrolling and zooming performance.
 */
- (void)mapViewRegionDidChange:(RMMapView *)mapView;

- (void) beforeMapRotate: (RMMapView*) map fromAngle: (CGFloat) angle;
- (void) afterMapRotate: (RMMapView*) map toAngle: (CGFloat) angle;

- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point;
- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point;

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map;
- (void) tapOnLabelForMarker: (RMMarker*) marker onMap: (RMMapView*) map;
- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event;
- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event;

- (void) afterMapTouch: (RMMapView*) map;

@end
