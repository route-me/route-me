//
//  RMPath.h
//
// Copyright (c) 2008, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

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
// This is the position on the map of the first point.

@property float lineWidth;
@property (nonatomic, assign) RMXYPoint origin;
@property (readwrite, assign) UIColor *lineColor;
@property (readwrite, assign) UIColor *fillColor;

- (void) addLineToXY: (RMXYPoint) point;
- (void) addLineToScreenPoint: (CGPoint) point;
- (void) addLineToLatLong: (RMLatLong) point;

// This closes the path, connecting the last point to the first.
// After this point, no further points can be added to the path.
- (void) closePath;

//- (void) setPoints: (NSArray*) arr;

//- (void) moveBy: (RMXYSize) delta;

@end
