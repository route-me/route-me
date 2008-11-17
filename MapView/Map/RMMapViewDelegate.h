//
//  RMMapViewDelegate.h
//  MapView
//
//  Created by Hauke Brandes on 31.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMMapView;
@class RMMarker;

@protocol RMMapViewDelegate 

@optional

- (void) beforeMapMove: (RMMapView*) map;
- (void) afterMapMove: (RMMapView*) map ;

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;
- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center;

- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point;

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map;

@end
