//
//  ScreenProjection.h
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMercator.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@protocol RMTileSource;

////////////////////////////// NOT COMPLETE. DO NOT USE

@interface RMTiledLayerController : NSObject
{
	CATiledLayer *layer;
	
//	MercatorPoint topLeft;
	
	// Size in pixels
//	CGSize viewSize;
	
	// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	// Scale of 1 means 1 pixel == 1 meter.
	// Scale of 10 means 1 pixel == 10 meters.
	float scale;
	
	id tileSource;
}

-(id) initWithTileSource: (id <RMTileSource>) tileSource;

-(void) setScale: (float) scale;

-(void) centerMercator: (RMMercatorPoint) point Animate: (BOOL) animate;
-(void) centerLatLong: (CLLocationCoordinate2D) point Animate: (BOOL) animate;
-(void) dragBy: (CGSize) delta;
-(void) zoomByFactor: (float) zoomFactor Near:(CGPoint) center;

/*
-(CGPoint) projectMercatorPoint: (MercatorPoint) point;
-(CGRect) projectMercatorRect: (MercatorRect) rect;

-(MercatorPoint) projectInversePoint: (CGPoint) point;
-(MercatorRect) projectInverseRect: (CGRect) rect;

-(MercatorRect) bounds;
*/
@property (assign, readwrite, nonatomic) float scale;
@property (readonly, nonatomic) CATiledLayer *layer;

@end
