/*
 *  MathUtils.c
 *  RouteMe
 *
 *  Created by Joseph Gentle on 8/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "RMPixel.h"

CGPoint RMScaleCGPointAboutPoint(CGPoint point, float factor, CGPoint pivot)
{
	point.x = (point.x - pivot.x) * factor + pivot.x;
	point.y = (point.y - pivot.y) * factor + pivot.y;
	
	return point;
}

CGRect RMScaleCGRectAboutPoint(CGRect rect, float factor, CGPoint pivot)
{
	rect.origin = RMScaleCGPointAboutPoint(rect.origin, factor, pivot);
	rect.size.width *= factor;
	rect.size.height *= factor;

	return rect;
}

CGPoint RMTranslateCGPointBy(CGPoint point, CGSize delta)
{
	point.x += delta.width;
	point.y += delta.height;
	return point;
}

CGRect RMTranslateCGRectBy(CGRect rect, CGSize delta)
{
	rect.origin = RMTranslateCGPointBy(rect.origin, delta);
	return rect;
}
