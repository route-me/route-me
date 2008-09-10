/*
 *  MathUtils.c
 *  RouteMe
 *
 *  Created by Joseph Gentle on 8/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "MathUtils.h"

CGRect ScaleCGRectAboutPoint(CGRect rect, float factor, CGPoint point)
{
	rect.origin.x = (rect.origin.x - point.x) * factor + point.x;
	rect.origin.y = (rect.origin.y - point.y) * factor + point.y;
	rect.size.width *= factor;
	rect.size.height *= factor;

	return rect;
}

CGPoint TranslateCGPointBy(CGPoint point, CGSize delta)
{
	point.x += delta.width;
	point.y += delta.height;
	return point;
}

CGRect TranslateCGRectBy(CGRect rect, CGSize delta)
{
	rect.origin = TranslateCGPointBy(rect.origin, delta);
	return rect;
}
