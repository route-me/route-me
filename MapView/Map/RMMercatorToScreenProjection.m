//
//  RMMercatorToScreenProjection.m
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
#import "RMGlobalConstants.h"
#import "RMMercatorToScreenProjection.h"
#include "RMProjection.h"

@implementation RMMercatorToScreenProjection

- (id) initFromProjection: (RMProjection*) aProjection ToScreenBounds: (CGRect)aScreenBounds;
{
	if (![super init])
		return nil;
	screenBounds = aScreenBounds;
	projection = [aProjection retain];
	metersPerPixel = 1;
	return self;
}

- (void) dealloc
{
	[projection release];
	[super dealloc];
}

// Deltas in screen coordinates.
- (RMProjectedPoint)movePoint: (RMProjectedPoint)aPoint by:(CGSize) delta
{
	RMProjectedSize XYDelta = [self projectScreenSizeToXY:delta];
	aPoint.easting += XYDelta.width;
	aPoint.northing += XYDelta.height;
	aPoint = [projection wrapPointHorizontally:aPoint];
	return aPoint;
}

- (RMProjectedRect)moveRect: (RMProjectedRect)aRect by:(CGSize) delta
{
	aRect.origin = [self movePoint:aRect.origin by:delta];
	return aRect;
}

- (RMProjectedPoint)zoomPoint: (RMProjectedPoint)aPoint byFactor: (float)factor near:(CGPoint) aPixelPoint
{
	RMProjectedPoint XYPivot = [self projectScreenPointToXY:aPixelPoint];
	RMProjectedPoint result = RMScaleProjectedPointAboutPoint(aPoint, factor, XYPivot);
	result = [projection wrapPointHorizontally:result];
//	RMLog(@"RMScaleMercatorPointAboutPoint %f %f about %f %f to %f %f", point.x, point.y, mercatorPivot.x, mercatorPivot.y, result.x, result.y);
	return result;
}

- (RMProjectedRect)zoomRect: (RMProjectedRect)aRect byFactor: (float)factor near:(CGPoint) aPixelPoint
{
	RMProjectedPoint XYPivot = [self projectScreenPointToXY:aPixelPoint];
	RMProjectedRect result = RMScaleProjectedRectAboutPoint(aRect, factor, XYPivot);
	result.origin = [projection wrapPointHorizontally:result.origin];
	return result;
}

-(void) moveScreenBy: (CGSize)delta
{
//	RMLog(@"move screen from %f %f", origin.easting, origin.y);

//	origin.easting -= delta.width * scale;
//	origin.y += delta.height * scale;

	// Reverse the delta - if the screen's contents moves left, the origin moves right.
	// It makes sense if you think about it long enough and squint your eyes a bit.

	delta.width = -delta.width;
	delta.height = -delta.height;
	origin = [self movePoint:origin by:delta];
	
//	RMLog(@"to %f %f", origin.easting, origin.y);
}

- (void) zoomScreenByFactor: (float) factor near:(CGPoint) aPixelPoint;
{
	// The result of this function should be the same as this:
	//RMMercatorPoint test = [self zoomPoint:origin ByFactor:1.0f / factor Near:pivot];

	// First we move the origin to the pivot...
	origin.easting += aPixelPoint.x * metersPerPixel;
	origin.northing += (screenBounds.size.height - aPixelPoint.y) * metersPerPixel;
	// Then scale by 1/factor
	metersPerPixel /= factor;
	// Then translate back
	origin.easting -= aPixelPoint.x * metersPerPixel;
	origin.northing -= (screenBounds.size.height - aPixelPoint.y) * metersPerPixel;

	origin = [projection wrapPointHorizontally:origin];
	
	//RMLog(@"test: %f %f", test.x, test.y);
	//RMLog(@"correct: %f %f", origin.easting, origin.y);
	
//	CGPoint p = [self projectMercatorPoint:[self projectScreenPointToMercator:kTheOrigin]];
//	RMLog(@"origin at %f %f", p.x, p.y);
//	CGPoint q = [self projectMercatorPoint:[self projectScreenPointToMercator:CGPointMake(100,100)]];
//	RMLog(@"100 100 at %f %f", q.x, q.y);

}

- (void)zoomBy: (float) factor
{
	metersPerPixel *= factor;
}

- (CGPoint) projectXYPoint:(RMProjectedPoint)aPoint withMetersPerPixel:(float)aScale
{
	CGPoint	aPixelPoint;
   CGFloat originX = origin.easting;
   CGFloat boundsWidth = [projection planetBounds].size.width;
   CGFloat pointX = aPoint.easting - boundsWidth/2;
   CGFloat left = sqrt((pointX - (originX - boundsWidth))*(pointX - (originX - boundsWidth)));
   CGFloat middle = sqrt((pointX - originX)*(pointX - originX));
   CGFloat right = sqrt((pointX - (originX + boundsWidth))*(pointX - (originX + boundsWidth)));
   
   if(middle <= left && middle <= right){
      aPixelPoint.x = (aPoint.easting - originX) / aScale;
   } else if(left <= middle && left <= right){
      aPixelPoint.x = (aPoint.easting - (originX-boundsWidth)) / aScale;
   } else{ //right
      aPixelPoint.x = (aPoint.easting - (originX+boundsWidth)) / aScale;
   }
	
	aPixelPoint.y = screenBounds.size.height - (aPoint.northing - origin.northing) / aScale;
   return aPixelPoint;
}

- (CGPoint) projectXYPoint: (RMProjectedPoint)aPoint
{

	return [self projectXYPoint:aPoint withMetersPerPixel:metersPerPixel];
}

- (CGRect) projectXYRect: (RMProjectedRect) aRect
{
	CGRect aPixelRect;
	aPixelRect.origin = [self projectXYPoint: aRect.origin];
	aPixelRect.size.width = aRect.size.width / metersPerPixel;
	aPixelRect.size.height = aRect.size.height / metersPerPixel;
	return aPixelRect;
}

- (RMProjectedPoint)projectScreenPointToXY: (CGPoint) aPixelPoint withMetersPerPixel:(float)aScale
{
	RMProjectedPoint aPoint;
	aPoint.easting = origin.easting + aPixelPoint.x * aScale;
	aPoint.northing = origin.northing + (screenBounds.size.height - aPixelPoint.y) * aScale;
	
	origin = [projection wrapPointHorizontally:origin];
	
	return aPoint;
}

- (RMProjectedPoint) projectScreenPointToXY: (CGPoint) aPixelPoint
{
	// I will assume the point is within the screenbounds rectangle.
	
	return [projection wrapPointHorizontally:[self projectScreenPointToXY:aPixelPoint withMetersPerPixel:metersPerPixel]];
}

- (RMProjectedRect) projectScreenRectToXY: (CGRect) aPixelRect
{
	RMProjectedRect aRect;
	aRect.origin = [self projectScreenPointToXY: aPixelRect.origin];
	aRect.size.width = aPixelRect.size.width * metersPerPixel;
	aRect.size.height = aPixelRect.size.height * metersPerPixel;
	return aRect;
}

- (RMProjectedSize)projectScreenSizeToXY: (CGSize) aPixelSize
{
	RMProjectedSize aSize;
	aSize.width = aPixelSize.width * metersPerPixel;
	aSize.height = -aPixelSize.height * metersPerPixel;
	return aSize;
}

- (RMProjectedRect) projectedBounds
{
	RMProjectedRect aRect;
	aRect.origin = origin;
	aRect.size.width = screenBounds.size.width * metersPerPixel;
	aRect.size.height = screenBounds.size.height * metersPerPixel;
	return aRect;
}

-(void) setProjectedBounds: (RMProjectedRect) aRect
{
	float scaleX = aRect.size.width / screenBounds.size.width;
	float scaleY = aRect.size.height / screenBounds.size.height;
	
	// I will pick a scale in between those two.
	metersPerPixel = (scaleX + scaleY) / 2;
	origin = [projection wrapPointHorizontally:aRect.origin];
}

- (RMProjectedPoint) projectedCenter
{
	RMProjectedPoint aPoint;
	aPoint.easting = origin.easting + screenBounds.size.width * metersPerPixel / 2;
	aPoint.northing = origin.northing + screenBounds.size.height * metersPerPixel / 2;
	aPoint = [projection wrapPointHorizontally:aPoint];
	return aPoint;
}

- (void) setProjectedCenter: (RMProjectedPoint) aPoint
{
	origin = [projection wrapPointHorizontally:aPoint];
	origin.easting -= screenBounds.size.width * metersPerPixel / 2;
	origin.northing -= screenBounds.size.height * metersPerPixel / 2;
}

- (void) setScreenBounds:(CGRect)rect;
{
  screenBounds = rect;
}

-(CGRect) screenBounds
{
	return screenBounds;
}

-(float) metersPerPixel
{
	return metersPerPixel;
}

-(void) setMetersPerPixel: (float) newMPP
{
	// We need to adjust the origin - since the origin
	// is in the corner, it will change when we change the scale.
	
	RMProjectedPoint center = [self projectedCenter];
	metersPerPixel = newMPP;
	[self setProjectedCenter:center];
}

@end
