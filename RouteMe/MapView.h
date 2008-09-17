//
//  MapView.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mercator.h"
//#import "MapRenderer.h"
//#import "TileSource.h"

typedef struct {
	CGPoint center;
	float averageDistanceFromCenter;
} GestureDetails;

@protocol TileSource;
@class MapRenderer;
//@class TileSource;
//@class TileImageSet;

@interface MapView : UIView {
	id<TileSource> tileSource;
	MapRenderer *renderer;
	
	bool enableDragging;
	bool enableZoom;
	
	GestureDetails lastGesture;
}

-(void) moveToMercator: (MercatorPoint) point;
-(void) moveToLatLong: (CLLocationCoordinate2D) point;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

@property (readwrite) CLLocationCoordinate2D location;
@property (readwrite) float scale;

@property (assign, readwrite, nonatomic) bool enableDragging;
@property (assign, readwrite, nonatomic) bool enableZoom;
@property (retain, readwrite, nonatomic) id<TileSource> tileSource;

@end
