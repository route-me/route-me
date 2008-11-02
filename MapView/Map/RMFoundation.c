/*
 *  RMFoundation.c
 *  MapView
 *
 *  Created by David Bainbridge on 10/28/08.
 *
 */

#import "RMFoundation.h"


RMXYPoint RMScaleXYPointAboutPoint(RMXYPoint point, float factor, RMXYPoint pivot)
{
	point.x = (point.x - pivot.x) * factor + pivot.x;
	point.y = (point.y - pivot.y) * factor + pivot.y;
	
	return point;
}

RMXYRect  RMScaleXYRectAboutPoint (RMXYRect rect,   float factor, RMXYPoint pivot)
{
	rect.origin = RMScaleXYPointAboutPoint(rect.origin, factor, pivot);
	rect.size.width *= factor;
	rect.size.height *= factor;
	
	return rect;
}

RMXYPoint RMTranslateXYPointBy(RMXYPoint point, RMXYSize delta)
{
	point.x += delta.width;
	point.y += delta.height;
	return point;
}

RMXYRect  RMTranslateXYRectBy(RMXYRect rect,   RMXYSize delta)
{
	rect.origin = RMTranslateXYPointBy(rect.origin, delta);
	return rect;
}

RMXYPoint  RMXYMakePoint (double x, double y)
{
	RMXYPoint point = {
		x, y
	};
	
	return point;
}

RMXYRect  RMXYMakeRect (double x, double y, double width, double height)
{
	RMXYRect rect = {
		{x, y},
		{width, height}
	};
	
	return rect;
}
