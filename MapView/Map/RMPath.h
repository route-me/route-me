//
//  RMPolygon.h
//  Shapes
//
//  Created by Joseph Gentle on 11/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMMapLayer.h"

@class RMMapContents;
@class RMMapView;

@interface RMPath : RMMapLayer
{
	NSMutableArray *points;

	// This is the first point.
	RMXYPoint origin;
	
	// The color of the line and polygon's fill.
	UIColor *lineColor;
	UIColor *fillColor;
	
	CGMutablePathRef path;

	// Width of the line.
	float lineWidth;
	
	// Drawing mode of the path. Choices are:
	/* 
	 kCGPathFill,
	 kCGPathEOFill,
	 kCGPathStroke,
	 kCGPathFillStroke,
	 kCGPathEOFillStroke */
	CGPathDrawingMode drawingMode;
	
	BOOL scaleLineWidth;
	
	float renderedScale;
	RMMapContents *contents;
}

- (id) initWithContents: (RMMapContents*)aContents;
- (id) initForMap: (RMMapView*)map;

@property CGPathDrawingMode drawingMode;
@property (readwrite, assign) UIColor *lineColor;
@property (readwrite, assign) UIColor *fillColor;
// This is the position on the map of the first point.
@property (readwrite, assign) RMXYPoint origin;
@property float lineWidth;

- (void) addLineToXY: (RMXYPoint) point;
- (void) addLineToScreenPoint: (CGPoint) point;
- (void) addLineToLatLong: (RMLatLong) point;

// This closes the path, connecting the last point to the first.
// After this point, no further points can be added to the path.
- (void) closePath;

//- (void) setPoints: (NSArray*) arr;

//- (void) moveBy: (RMXYSize) delta;

@end
