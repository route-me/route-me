//
//  ScreenProjection.m
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMercatorToScreenProjection.h"


@implementation RMMercatorToScreenProjection

@synthesize scale;

-(id) initWithScreenBounds: (CGRect)_screenBounds
{
	if (![super init])
		return nil;
	screenBounds = _screenBounds;
	scale = 1;
	return self;
}

// Deltas in screen coordinates.
- (RMMercatorPoint)movePoint: (RMMercatorPoint)point By:(CGSize) delta
{
	RMMercatorSize mercatorDelta = [self projectScreenSizeToMercator:delta];
	point.x += mercatorDelta.width;
	point.y += mercatorDelta.height;
	return point;
}

- (RMMercatorRect)moveRect: (RMMercatorRect)rect By:(CGSize) delta
{
	rect.origin = [self movePoint:rect.origin By:delta];
	return rect;
}

- (RMMercatorPoint)zoomPoint: (RMMercatorPoint)point ByFactor: (float)factor Near:(CGPoint) pivot
{
	RMMercatorPoint mercatorPivot = [self projectScreenPointToMercator:pivot];
	return RMScaleMercatorPointAboutPoint(point, factor, mercatorPivot);	
}

- (RMMercatorRect)zoomRect: (RMMercatorRect)rect ByFactor: (float)factor Near:(CGPoint) pivot
{
	RMMercatorPoint mercatorPivot = [self projectScreenPointToMercator:pivot];
	return RMScaleMercatorRectAboutPoint(rect, factor, mercatorPivot);
}

-(void) moveScreenBy: (CGSize) delta
{
//	NSLog(@"move screen from %f %f", origin.x, origin.y);

//	origin.x -= delta.width * scale;
//	origin.y += delta.height * scale;

	// Reverse the delta - if the screen's contents moves left, the origin moves right.
	// It makes sense if you think about it long enough and squint your eyes a bit.

	delta.width = -delta.width;
	delta.height = -delta.height;
	origin = [self movePoint:origin By:delta];
	
//	NSLog(@"to %f %f", origin.x, origin.y);
}

- (void) zoomScreenByFactor: (float) factor Near:(CGPoint) pivot;
{
//	NSLog(@"zoomBy: %f", zoomFactor);
	origin.x += pivot.x * scale;
	origin.y += (screenBounds.size.height - pivot.y) * scale;
	scale /= factor;
	origin.x -= pivot.x * scale;
	origin.y -= (screenBounds.size.height - pivot.y) * scale;

//	origin = [self zoomPoint:origin ByFactor:factor Near:pivot];
}

- (void)zoomBy: (float) factor
{
	scale *= factor;
}

-(CGPoint) projectMercatorPoint: (RMMercatorPoint) mercator
{
	CGPoint point;
	point.x = (mercator.x - origin.x) / scale;
	point.y = -(mercator.y - origin.y) / scale;
	return point;
}

-(CGRect) projectMercatorRect: (RMMercatorRect) mercator
{
	CGRect rect;
	rect.origin = [self projectMercatorPoint: mercator.origin];
	mercator.size.width = rect.size.width / scale;
	mercator.size.height = rect.size.height / scale;
	return rect;
}

-(RMMercatorPoint) projectScreenPointToMercator: (CGPoint) point
{
	// There is something wrong with this code
	NSAssert(NO, @"There is something dreadfully wrong with this code but its late and I'm tired.");
	RMMercatorPoint mercatorPoint;
	mercatorPoint.x = origin.x + (point.x - screenBounds.origin.x) * scale;
	mercatorPoint.y = origin.y + (screenBounds.size.height - point.y + screenBounds.origin.y) * scale;
	return mercatorPoint;
}

-(RMMercatorRect) projectScreenRectToMercator: (CGRect) rect
{
	RMMercatorRect mercator;
	mercator.origin = [self projectScreenPointToMercator: rect.origin];
	mercator.size.width = rect.size.width * scale;
	mercator.size.height = rect.size.height * scale;
	return mercator;
}

- (RMMercatorSize)projectScreenSizeToMercator: (CGSize) size
{
	RMMercatorSize mercatorSize;
	mercatorSize.width = size.width * scale;
	mercatorSize.height = -size.height * scale;
	return mercatorSize;
}

-(RMMercatorRect) mercatorBounds
{
	RMMercatorRect rect;
	rect.origin = origin;
	rect.size.width = screenBounds.size.width * scale;
	rect.size.height = screenBounds.size.height * scale;
	return rect;
}

-(void) setMercatorBounds: (RMMercatorRect) bounds
{
	float scaleX = bounds.size.width / screenBounds.size.width;
	float scaleY = bounds.size.height / screenBounds.size.height;
	
	// I will pick a scale in between those two.
	scale = (scaleX + scaleY) / 2;
	origin = bounds.origin;
}

-(RMMercatorPoint) mercatorCenter
{
	RMMercatorPoint point;
	point.x = origin.x + screenBounds.size.width * scale / 2;
	point.y = origin.y + screenBounds.size.height * scale / 2;
	return point;
}

-(void) setMercatorCenter: (RMMercatorPoint) center
{
	origin = center;
	origin.x -= screenBounds.size.width * scale / 2;
	origin.y -= screenBounds.size.height * scale / 2;
}

-(CGRect) screenBounds
{
	return screenBounds;
}

@end
