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
	factor = 1.0f / factor;
	rect.origin.x = (rect.origin.x - point.x) * factor + point.x;
	rect.origin.y = (rect.origin.y - point.y) * factor + point.y;
	rect.size.width *= factor;
	rect.size.height *= factor;

	return rect;
}

CGRect TranslateCGRectBy(CGRect rect, CGSize delta)
{
	rect.origin.x += delta.width;
	rect.origin.y += delta.height;
	return rect;
}