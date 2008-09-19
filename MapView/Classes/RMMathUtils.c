/*
 *  MathUtils.c
 *  RouteMe
 *
 *  Created by Joseph Gentle on 8/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "RMMathUtils.h"

CGRect RMScaleCGRectAboutPoint(CGRect rect, float factor, CGPoint point)
{
	rect.origin.x = (rect.origin.x - point.x) * factor + point.x;
	rect.origin.y = (rect.origin.y - point.y) * factor + point.y;
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
