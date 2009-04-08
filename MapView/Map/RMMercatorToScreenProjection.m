//
//  RMMercatorToScreenProjection.m
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

#import "RMMercatorToScreenProjection.h"
#include "RMProjection.h"

@implementation RMMercatorToScreenProjection

- (id) initFromProjection: (RMProjection*) aProjection ToScreenBounds: (CGRect)aScreenBounds;
{
	if (![super init])
		return nil;
	screenBounds = aScreenBounds;
	projection = [aProjection retain];
	scale = 1;
	return self;
}

- (void) dealloc
{
	[projection release];
	[super dealloc];
}

// Deltas in screen coordinates.
- (RMXYPoint)movePoint: (RMXYPoint)aPoint by:(CGSize) delta
{
	RMXYSize XYDelta = [self projectScreenSizeToXY:delta];
	aPoint.x += XYDelta.width;
	aPoint.y += XYDelta.height;
	aPoint = [projection wrapPointHorizontally:aPoint];
	return aPoint;
}

- (RMXYRect)moveRect: (RMXYRect)aRect by:(CGSize) delta
{
	aRect.origin = [self movePoint:aRect.origin by:delta];
	return aRect;
}

- (RMXYPoint)zoomPoint: (RMXYPoint)aPoint byFactor: (float)factor near:(CGPoint) aPixelPoint
{
	RMXYPoint XYPivot = [self projectScreenPointToXY:aPixelPoint];
	RMXYPoint result = RMScaleXYPointAboutPoint(aPoint, factor, XYPivot);
	result = [projection wrapPointHorizontally:result];
//	RMLog(@"RMScaleMercatorPointAboutPoint %f %f about %f %f to %f %f", point.x, point.y, mercatorPivot.x, mercatorPivot.y, result.x, result.y);
	return result;
}

- (RMXYRect)zoomRect: (RMXYRect)aRect byFactor: (float)factor near:(CGPoint) aPixelPoint
{
	RMXYPoint XYPivot = [self projectScreenPointToXY:aPixelPoint];
	RMXYRect result = RMScaleXYRectAboutPoint(aRect, factor, XYPivot);
	result.origin = [projection wrapPointHorizontally:result.origin];
	return result;
}

-(void) moveScreenBy: (CGSize)delta
{
//	RMLog(@"move screen from %f %f", origin.x, origin.y);

//	origin.x -= delta.width * scale;
//	origin.y += delta.height * scale;

	// Reverse the delta - if the screen's contents moves left, the origin moves right.
	// It makes sense if you think about it long enough and squint your eyes a bit.

	delta.width = -delta.width;
	delta.height = -delta.height;
	origin = [self movePoint:origin by:delta];
	
//	RMLog(@"to %f %f", origin.x, origin.y);
}

- (void) zoomScreenByFactor: (float) factor near:(CGPoint) aPixelPoint;
{
	// The result of this function should be the same as this:
	//RMMercatorPoint test = [self zoomPoint:origin ByFactor:1.0f / factor Near:pivot];

	// First we move the origin to the pivot...
	origin.x += aPixelPoint.x * scale;
	origin.y += (screenBounds.size.height - aPixelPoint.y) * scale;
	// Then scale by 1/factor
	scale /= factor;
	// Then translate back
	origin.x -= aPixelPoint.x * scale;
	origin.y -= (screenBounds.size.height - aPixelPoint.y) * scale;

	origin = [projection wrapPointHorizontally:origin];
	
	//RMLog(@"test: %f %f", test.x, test.y);
	//RMLog(@"correct: %f %f", origin.x, origin.y);
	
//	CGPoint p = [self projectMercatorPoint:[self projectScreenPointToMercator:CGPointMake(0,0)]];
//	RMLog(@"origin at %f %f", p.x, p.y);
//	CGPoint q = [self projectMercatorPoint:[self projectScreenPointToMercator:CGPointMake(100,100)]];
//	RMLog(@"100 100 at %f %f", q.x, q.y);

}

- (void)zoomBy: (float) factor
{
	scale *= factor;
}

- (CGPoint) projectXYPoint:(RMXYPoint)aPoint withScale:(float)aScale
{
	CGPoint	aPixelPoint;
   CGFloat originX = origin.x;
   CGFloat boundsWidth = [projection bounds].size.width;
   CGFloat pointX = aPoint.x - boundsWidth/2;
   CGFloat left = sqrt((pointX - (originX - boundsWidth))*(pointX - (originX - boundsWidth)));
   CGFloat middle = sqrt((pointX - originX)*(pointX - originX));
   CGFloat right = sqrt((pointX - (originX + boundsWidth))*(pointX - (originX + boundsWidth)));
   
   if(middle <= left && middle <= right){
      aPixelPoint.x = (aPoint.x - originX) / aScale;
   } else if(left <= middle && left <= right){
      aPixelPoint.x = (aPoint.x - (originX-boundsWidth)) / aScale;
   } else{ //right
      aPixelPoint.x = (aPoint.x - (originX+boundsWidth)) / aScale;
   }
	
	aPixelPoint.y = screenBounds.size.height - (aPoint.y - origin.y) / aScale;
   return aPixelPoint;
}

- (CGPoint) projectXYPoint: (RMXYPoint)aPoint
{

	return [self projectXYPoint:aPoint withScale:scale];
}

- (CGRect) projectXYRect: (RMXYRect) aRect
{
	CGRect aPixelRect;
	aPixelRect.origin = [self projectXYPoint: aRect.origin];
	aPixelRect.size.width = aRect.size.width / scale;
	aPixelRect.size.height = aRect.size.height / scale;
	return aPixelRect;
}

- (RMXYPoint)projectScreenPointToXY: (CGPoint) aPixelPoint withScale:(float)aScale
{
	RMXYPoint aPoint;
	aPoint.x = origin.x + aPixelPoint.x * aScale;
	aPoint.y = origin.y + (screenBounds.size.height - aPixelPoint.y) * aScale;
	
	origin = [projection wrapPointHorizontally:origin];
	
	return aPoint;
}

- (RMXYPoint) projectScreenPointToXY: (CGPoint) aPixelPoint
{
	// I will assume the point is within the screenbounds rectangle.
	
	return [projection wrapPointHorizontally:[self projectScreenPointToXY:aPixelPoint withScale:scale]];
}

- (RMXYRect) projectScreenRectToXY: (CGRect) aPixelRect
{
	RMXYRect aRect;
	aRect.origin = [self projectScreenPointToXY: aPixelRect.origin];
	aRect.size.width = aPixelRect.size.width * scale;
	aRect.size.height = aPixelRect.size.height * scale;
	return aRect;
}

- (RMXYSize)projectScreenSizeToXY: (CGSize) aPixelSize
{
	RMXYSize aSize;
	aSize.width = aPixelSize.width * scale;
	aSize.height = -aPixelSize.height * scale;
	return aSize;
}

- (RMXYRect) XYBounds
{
	RMXYRect aRect;
	aRect.origin = origin;
	aRect.size.width = screenBounds.size.width * scale;
	aRect.size.height = screenBounds.size.height * scale;
	return aRect;
}

-(void) setXYBounds: (RMXYRect) aRect
{
	float scaleX = aRect.size.width / screenBounds.size.width;
	float scaleY = aRect.size.height / screenBounds.size.height;
	
	// I will pick a scale in between those two.
	scale = (scaleX + scaleY) / 2;
	origin = [projection wrapPointHorizontally:aRect.origin];
}

- (RMXYPoint) XYCenter
{
	RMXYPoint aPoint;
	aPoint.x = origin.x + screenBounds.size.width * scale / 2;
	aPoint.y = origin.y + screenBounds.size.height * scale / 2;
	aPoint = [projection wrapPointHorizontally:aPoint];
	return aPoint;
}

- (void) setXYCenter: (RMXYPoint) aPoint
{
	origin = [projection wrapPointHorizontally:aPoint];
	origin.x -= screenBounds.size.width * scale / 2;
	origin.y -= screenBounds.size.height * scale / 2;
}

- (void) setScreenBounds:(CGRect)rect;
{
  screenBounds = rect;
}

-(CGRect) screenBounds
{
	return screenBounds;
}

-(float) scale
{
	return scale;
}

-(void) setScale: (float) newScale
{
	// We need to adjust the origin - since the origin
	// is in the corner, it will change when we change the scale.
	
	RMXYPoint center = [self XYCenter];
	scale = newScale;
	[self setXYCenter:center];
}

@end
