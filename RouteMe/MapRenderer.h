//
//  MapRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mercator.h"

@class MapView;
@class ScreenProjection;

@interface MapRenderer : NSObject
{
	ScreenProjection *screenProjection;
	MapView *view;
}

// Designated initialiser
- (id) initWithView: (MapView *)_view ProjectingIn: (ScreenProjection*) _screenProjection;
// This makes a screen projection from the view
- (id) initWithView: (MapView *)view;

- (void)drawRect:(CGRect)rect;

-(void) moveToMercator: (MercatorPoint) point;
-(void) moveToLatLong: (CLLocationCoordinate2D) point;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

-(void) recalculateImageSet;
- (void)setNeedsDisplay;

@property (readwrite) double scale;

@end
