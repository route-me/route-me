//
//  RMMapContents.h
//  MapView
//
//  Created by Joseph Gentle on 24/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMTile.h"

#import "RMTilesUpdateDelegate.h"


// constants for boundingMask
enum {
	// Map can be zoomed out past view limits
	RMMapNoMinBound			= 0,
	// Minimum map height when zooming out restricted to view height
	RMMapMinHeightBound		= 1,
	// Minimum map width when zooming out restricted to view width ( default )
	RMMapMinWidthBound		= 2
};

@class RMMarkerManager;
@class RMProjection;
@class RMMercatorToScreenProjection;
@class RMTileImageSet;
@class RMTileLoader;
@class RMMapRenderer;
@class RMMapLayer;
@class RMLayerSet;
@class RMMarker;
@protocol RMMercatorToTileProjection;
@protocol RMTileSource;

@interface RMMapContents : NSObject
{
	// TODO: Also support NSView.
	
	// This is the underlying UIView's layer.
	CALayer *layer;
	
	RMMarkerManager *markerManager;
	RMMapLayer *background;
	RMLayerSet *overlay;
	
	// Latlong is calculated dynamically from mercatorBounds.
	RMProjection *projection;
	
	id<RMMercatorToTileProjection> mercatorToTileProjection;
//	RMTileRect tileBounds;
	
	RMMercatorToScreenProjection *mercatorToScreenProjection;
	
	id<RMTileSource> tileSource;
	
	RMTileImageSet *imagesOnScreen;
	RMTileLoader *tileLoader;
	
	RMMapRenderer *renderer;
	NSUInteger		boundingMask;
	
	float minZoom, maxZoom;

	id<RMTilesUpdateDelegate> tilesUpdateDelegate;
}

@property (readwrite) CLLocationCoordinate2D mapCenter;
@property (readwrite) RMXYRect XYBounds;
@property (readonly)  RMTileRect tileBounds;
@property (readonly)  CGRect screenBounds;
@property (readwrite) float scale;
@property (readwrite) float zoom;

@property (readwrite) float minZoom, maxZoom;

@property (readonly)  RMTileImageSet *imagesOnScreen;

@property (readonly)  RMProjection *projection;
@property (readonly)  id<RMMercatorToTileProjection> mercatorToTileProjection;
@property (readonly)  RMMercatorToScreenProjection *mercatorToScreenProjection;

@property (retain, readwrite) id<RMTileSource> tileSource;
@property (retain, readwrite) RMMapRenderer *renderer;

@property (readonly)  CALayer *layer;

@property (retain, readwrite) RMMapLayer *background;
@property (retain, readwrite) RMLayerSet *overlay;
@property (retain, readonly)  RMMarkerManager *markerManager;
@property (nonatomic, retain) id<RMTilesUpdateDelegate> tilesUpdateDelegate;
@property (readwrite) NSUInteger boundingMask;

- (id) initForView: (UIView*) view;
- (id) initForView: (UIView*) view WithLocation:(CLLocationCoordinate2D)latlong;

// Designated initialiser
- (id)initForView:(UIView*)view WithTileSource:(id<RMTileSource>)tileSource WithRenderer:(RMMapRenderer*)renderer LookingAt:(CLLocationCoordinate2D)latlong;

- (void) didReceiveMemoryWarning;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToXYPoint: (RMXYPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (float)adjustZoomForBoundingMask:(float)zoomFactor;
- (void)adjustMapPlacementWithScale:(float)aScale;
- (void)setZoomBounds:(float)aMinZoom maxZoom:(float)aMaxZoom;

- (void) drawRect: (CGRect) rect;

//-(void)addLayer: (id<RMMapLayer>) layer above: (id<RMMapLayer>) other;
//-(void)addLayer: (id<RMMapLayer>) layer below: (id<RMMapLayer>) other;
//-(void)removeLayer: (id<RMMapLayer>) layer;

// During touch and move operations on the iphone its good practice to
// hold off on any particularly expensive operations so the user's 
+ (BOOL) performExpensiveOperations;
+ (void) setPerformExpensiveOperations: (BOOL)p;

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withScale:(float)aScale;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withScale:(float)aScale;

- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)zoomWithRMMercatorRectBounds:(RMXYRect)bounds;

- (RMLatLongBounds) getScreenCoordinateBounds;
- (RMLatLongBounds) getCoordinateBounds:(CGRect) rect;

- (void) tilesUpdatedRegion:(CGRect)region;

@end
