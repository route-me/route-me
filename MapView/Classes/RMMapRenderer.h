//
//  MapRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMercator.h"

@class CALayer;
@protocol RMTileSource;

@protocol RenderingTarget<NSObject>

-(void) setNeedsDisplay;
-(CGRect) cgBounds;
-(id<RMTileSource>) tileSource;
@optional
-(CALayer*) layer;

@end


@class RMScreenProjection;

@interface RMMapRenderer : NSObject
{
	RMScreenProjection *screenProjection;
	id<RenderingTarget> view;
}

// Designated initialiser
- (id) initWithView: (id<RenderingTarget>)_view ProjectingIn: (RMScreenProjection*) _screenProjection;
// This makes a screen projection from the view
- (id) initWithView: (id<RenderingTarget>)view;

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
