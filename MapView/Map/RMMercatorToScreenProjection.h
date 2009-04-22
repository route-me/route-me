//
//  RMMercatorToScreenProjection.h
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "RMFoundation.h"

@class RMProjection;

/// This is a stateful projection. As the screen moves around, so too do projections change.
@interface RMMercatorToScreenProjection : NSObject
{
	/// What the screen is currently looking at.
	RMProjectedPoint origin;

	/// The mercator -or-whatever- projection that the map is in.
	/// This projection move linearly with the screen.
	RMProjection *projection;
	
	/// Bounds of the screen in pixels
	CGRect screenBounds;

	/// \brief meters per pixel
	/// \note The current usage of the term "scale" in Route-Me conflicts with standard cartographic usage, and will be changed after 0.5
	///
	/// Scale is how many meters in 1 pixel. Larger scale means bigger things are smaller on the screen.
	/// Scale of 1 means 1 pixel == 1 meter.
	/// Scale of 10 means 1 pixel == 10 meters.
	float scale;
}

- (id) initFromProjection: (RMProjection*) projection ToScreenBounds: (CGRect)aScreenBounds;

/// Deltas in screen coordinates.
- (RMProjectedPoint)movePoint: (RMProjectedPoint)aPoint by:(CGSize) delta;
/// Deltas in screen coordinates.
- (RMProjectedRect)moveRect: (RMProjectedRect)aRect by:(CGSize) delta;

/// pivot given in screen coordinates.
- (RMProjectedPoint)zoomPoint: (RMProjectedPoint)aPoint byFactor: (float)factor near:(CGPoint) pivot;
/// pivot given in screen coordinates.
- (RMProjectedRect)zoomRect: (RMProjectedRect)aRect byFactor: (float)factor near:(CGPoint) pivot;

/// Move the screen.
- (void) moveScreenBy: (CGSize) delta;
- (void) zoomScreenByFactor: (float) factor near:(CGPoint) aPoint;

/// Project -> screen coordinates.
- (CGPoint)projectXYPoint:(RMProjectedPoint)aPoint withScale:(float)aScale;
/// Project -> screen coordinates.
- (CGPoint) projectXYPoint: (RMProjectedPoint) aPoint;
/// Project -> screen coordinates.
- (CGRect) projectXYRect: (RMProjectedRect) aRect;

- (RMProjectedPoint) projectScreenPointToXY: (CGPoint) aPoint;
- (RMProjectedRect) projectScreenRectToXY: (CGRect) aRect;
- (RMProjectedSize)projectScreenSizeToXY: (CGSize) aSize;
- (RMProjectedPoint)projectScreenPointToXY: (CGPoint) aPixelPoint withScale:(float)aScale;

- (RMProjectedRect) projectedBounds;
- (void) setProjectedBounds: (RMProjectedRect) bounds;
- (RMProjectedPoint) projectedCenter;
- (void) setProjectedCenter: (RMProjectedPoint) aPoint;
- (void) setScreenBounds:(CGRect)rect;
- (CGRect) screenBounds;

@property (assign, readwrite) float scale;


@end
