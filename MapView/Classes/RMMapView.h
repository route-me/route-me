//
//  MapView.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <TargetConditionals.h>

///// This class is only valid for the iphone.
#if !TARGET_OS_IPHONE
#error This is only valid on the iphone.
#endif

#import <UIKit/UIKit.h>

#import "RMMercator.h"
#import "RMMapRenderer.h"
//#import "TileSource.h"

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
	int numTouches;
} RMGestureDetails;

@protocol RMTileSource;
@class RMMapRenderer;
//@class TileSource;
//@class TileImageSet;

@interface RMMapView : UIView<RMRenderingTarget> {
	id<RMTileSource> tileSource;
	RMMapRenderer *renderer;
	
	bool enableDragging;
	bool enableZoom;
	
	RMGestureDetails lastGesture;
}

-(void) moveToMercator: (RMMercatorPoint) point;
-(void) moveToLatLong: (CLLocationCoordinate2D) point;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@property (readwrite) CLLocationCoordinate2D location;
@property (readwrite) float scale;

@property (assign, readwrite, nonatomic) bool enableDragging;
@property (assign, readwrite, nonatomic) bool enableZoom;
@property (retain, readwrite, nonatomic) id<RMTileSource> tileSource;

@end

