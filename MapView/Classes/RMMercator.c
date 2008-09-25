/*
 *  RMMercator.c
 *  MapView
 *
 *  Created by Joseph Gentle on 24/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "RMMercator.h"

RMMercatorPoint RMScaleMercatorPointAboutPoint(RMMercatorPoint point, float factor, RMMercatorPoint pivot)
{
	point.x = (point.x - pivot.x) * factor + pivot.x;
	point.y = (point.y - pivot.y) * factor + pivot.y;
	
	return point;
}

RMMercatorRect  RMScaleMercatorRectAboutPoint (RMMercatorRect rect,   float factor, RMMercatorPoint pivot)
{
	rect.origin = RMScaleMercatorPointAboutPoint(rect.origin, factor, pivot);
	rect.size.width *= factor;
	rect.size.height *= factor;
	
	return rect;
}

RMMercatorPoint RMTranslateMercatorPointBy(RMMercatorPoint point, RMMercatorSize delta)
{
	point.x += delta.width;
	point.y += delta.height;
	return point;
}

RMMercatorRect  RMTranslateMercatorRectBy(RMMercatorRect rect,   RMMercatorSize delta)
{
	rect.origin = RMTranslateMercatorPointBy(rect.origin, delta);
	return rect;
}
