//
//  RMPath.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

/*! \brief buggy, incomplete, untested; overlays paths/polygons on map
 */
@interface RMPath : RMMapLayer <RMMovingMapLayer>
{
	BOOL	isFirstPoint;

	/// This is the first point.
	RMProjectedPoint projectedLocation;
	
	/// The color of the line, or the outline if a polygon
	UIColor *lineColor;
	/// The color of polygon's fill.
	UIColor *fillColor;
	
	CGMutablePathRef path;

	/// Width of the line, units unknown; pixels maybe?
	float lineWidth;
	
	/*! Drawing mode of the path; Choices are
	 kCGPathFill,
	 kCGPathEOFill,
	 kCGPathStroke,
	 kCGPathFillStroke,
	 kCGPathEOFillStroke */
	CGPathDrawingMode drawingMode;
	
	//Line cap and join styles
	CGLineCap lineCap;
	CGLineJoin lineJoin;	
	BOOL scaleLineWidth;
	BOOL enableDragging;
	BOOL enableRotation;
	
	float renderedScale;
	RMMapContents *contents;
}


- (id) initWithContents: (RMMapContents*)aContents;
- (id) initForMap: (RMMapView*)map;

@property CGPathDrawingMode drawingMode;
@property CGLineCap lineCap;
@property CGLineJoin lineJoin;
@property float lineWidth;
@property BOOL	scaleLineWidth;
@property (nonatomic, assign) RMProjectedPoint projectedLocation;
@property (assign) BOOL enableDragging;
@property (assign) BOOL enableRotation;
@property (readwrite, assign) UIColor *lineColor;
@property (readwrite, assign) UIColor *fillColor;

- (void) moveToXY: (RMProjectedPoint) point;
- (void) moveToScreenPoint: (CGPoint) point;
- (void) moveToLatLong: (RMLatLong) point;
- (void) addLineToXY: (RMProjectedPoint) point;
- (void) addLineToScreenPoint: (CGPoint) point;
- (void) addLineToLatLong: (RMLatLong) point;

/// This closes the path, connecting the last point to the first.
/// After this action, no further points can be added to the path.
/// There is no requirement that a path be closed.
- (void) closePath;


@end
