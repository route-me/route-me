//
//  ScreenProjection.m
//  Images
//
//  Created by Joseph Gentle on 28/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMercatorToScreenProjection.h"


@implementation RMMercatorToScreenProjection

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
	RMMercatorPoint result = RMScaleMercatorPointAboutPoint(point, factor, mercatorPivot);
//	NSLog(@"RMScaleMercatorPointAboutPoint %f %f about %f %f to %f %f", point.x, point.y, mercatorPivot.x, mercatorPivot.y, result.x, result.y);
	return result;
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
	// The result of this function should be the same as this:
	//RMMercatorPoint test = [self zoomPoint:origin ByFactor:1.0f / factor Near:pivot];

	// First we move the origin to the pivot...
	origin.x += pivot.x * scale;
	origin.y += (screenBounds.size.height - pivot.y) * scale;
	// Then scale by 1/factor
	scale /= factor;
	// Then translate back
	origin.x -= pivot.x * scale;
	origin.y -= (screenBounds.size.height - pivot.y) * scale;

	//NSLog(@"test: %f %f", test.x, test.y);
	//NSLog(@"correct: %f %f", origin.x, origin.y);
	
//	CGPoint p = [self projectMercatorPoint:[self projectScreenPointToMercator:CGPointMake(0,0)]];
//	NSLog(@"origin at %f %f", p.x, p.y);
//	CGPoint q = [self projectMercatorPoint:[self projectScreenPointToMercator:CGPointMake(100,100)]];
//	NSLog(@"100 100 at %f %f", q.x, q.y);

}

- (void)zoomBy: (float) factor
{
	scale *= factor;
}

-(CGPoint) projectMercatorPoint: (RMMercatorPoint) mercator
{
	CGPoint point;
	/*Old calculation of point.x was flawed in the case of a negative mercator.x and a positive origin.x value 
	 (like Los Angeles' mercator) where the actual difference between mercator.x and origin.x was not calculated correctly.*/
	
	if(mercator.x > origin.x)
	{
		point.x = (mercator.x - origin.x) / scale;
	}
	else
	{
		point.x = (origin.x - mercator.x) / scale;
	}
	point.y = screenBounds.size.height - (mercator.y - origin.y) / scale;
	return point;
}


-(CGRect) projectMercatorRect: (RMMercatorRect) mercator
{
	CGRect rect;
	rect.origin = [self projectMercatorPoint: mercator.origin];
	rect.size.width = mercator.size.width / scale;
	rect.size.height = mercator.size.height / scale;
	return rect;
}

-(RMMercatorPoint) projectScreenPointToMercator: (CGPoint) point
{
	// I will assume the point is within the screenbounds rectangle.
	
	RMMercatorPoint mercatorPoint;
	mercatorPoint.x = origin.x + point.x * scale;
	mercatorPoint.y = origin.y + (screenBounds.size.height - point.y) * scale;

//	NSLog(@"point %f %f -> %f %f", point.x, point.y, mercatorPoint.x, mercatorPoint.y);
//	NSLog(@"origin: %f %f", origin.x, origin.y);
//	NSLog(@"origin: %f %f", origin.x, origin.y);
	
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

-(float) scale
{
	return scale;
}

-(void) setScale: (float) newScale
{
	// We need to adjust the origin - since the origin
	// is in the corner, it will change when we change the scale.
	
	RMMercatorPoint center = [self mercatorCenter];
	scale = newScale;
	[self setMercatorCenter:center];
}

@end
