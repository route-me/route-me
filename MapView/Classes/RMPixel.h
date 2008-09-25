/*
 *  MathUtils.h
 *  RouteMe
 *
 *  Created by Joseph Gentle on 8/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MATHUTILS_H_
#define _MATHUTILS_H_

// Pixel coordinates are stored using apple-standard CGRects.

#include <CoreGraphics/CGGeometry.h>

CGPoint RMScaleCGPointAboutPoint(CGPoint point, float factor, CGPoint pivot);
CGRect RMScaleCGRectAboutPoint(CGRect rect, float factor, CGPoint pivot);
CGPoint RMTranslateCGPointBy(CGPoint point, CGSize delta);
CGRect RMTranslateCGRectBy(CGRect rect, CGSize delta);

#endif