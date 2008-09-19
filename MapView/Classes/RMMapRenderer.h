//
//  MapRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMercator.h"

@class RMMapView;
@class RMScreenProjection;

@interface RMMapRenderer : NSObject
{
	RMScreenProjection *screenProjection;
	RMMapView *view;
}

// Designated initialiser
- (id) initWithView: (RMMapView *)_view ProjectingIn: (RMScreenProjection*) _screenProjection;
// This makes a screen projection from the view
- (id) initWithView: (RMMapView *)view;

- (void)drawRect:(CGRect)rect;

-(void) moveToMercator: (RMMercatorPoint) point;
-(void) moveToLatLong: (CLLocationCoordinate2D) point;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) recalculateImageSet;
- (void)setNeedsDisplay;

@property (readwrite) double scale;

@property (readonly) RMScreenProjection *screenProjection;

@end
