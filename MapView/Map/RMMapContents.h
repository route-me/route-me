//
//  RMMapContents.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMLatLong.h"
#import "RMMercator.h"
#import "RMTile.h"

@class RMLatLongToMercatorProjection;
@class RMMercatorToScreenProjection;
@class RMTileImageSet;
@class RMTileLoader;
@class RMMapRenderer;
@protocol RMMercatorToTileProjection;
@protocol RMTileSource;

@interface RMMapContents : NSObject
{
	// TODO: Also support NSView.
//	UIView *targetView;
	
	// Latlong is calculated dynamically from mercatorBounds.
	RMLatLongToMercatorProjection *latLongToMercatorProjection;
	
	id<RMMercatorToTileProjection> mercatorToTileProjection;
//	RMTileRect tileBounds;
	
	RMMercatorToScreenProjection *mercatorToScreenProjection;
	
	id<RMTileSource> tileSource;
	
	RMTileImageSet *imagesOnScreen;
	RMTileLoader *tileLoader;
	
	RMMapRenderer *renderer;
}

@property (readwrite) CLLocationCoordinate2D mapCenter;
@property (readwrite) RMMercatorRect mercatorBounds;
@property (readonly)  RMTileRect tileBounds;
@property (readonly)  CGRect screenBounds;
@property (readwrite) float scale;
@property (readwrite) float zoom;

@property (readonly)  RMTileImageSet *imagesOnScreen;

@property (readonly)  RMLatLongToMercatorProjection *latLongToMercatorProjection;
@property (readonly)  id<RMMercatorToTileProjection> mercatorToTileProjection;
@property (readonly)  RMMercatorToScreenProjection *mercatorToScreenProjection;

@property (readonly)  id<RMTileSource> tileSource;

- (id) initForView: (UIView*) view;

// Designated initialiser
- (id) initForView: (UIView*) view WithTileSource: (id<RMTileSource>)tileSource WithRenderer: (RMMapRenderer*) renderer LookingAt:(CLLocationCoordinate2D)latlong;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToMercator: (RMMercatorPoint)mercator;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

- (void) drawRect: (CGRect) rect;

//-(void)addLayer: (id<RMMapLayer>) layer above: (id<RMMapLayer>) other;
//-(void)addLayer: (id<RMMapLayer>) layer below: (id<RMMapLayer>) other;
//-(void)removeLayer: (id<RMMapLayer>) layer;

// During touch and move operations on the iphone its good practice to
// hold off on any particularly expensive operations so the user's 
+ (BOOL) performExpensiveOperations;
+ (void) setPerformExpensiveOperations: (BOOL)p;

@end
