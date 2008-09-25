/*
 *  RMMercator.h
 *  MapView
 *
 *  Created by Joseph Gentle on 24/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <CoreGraphics/CGGeometry.h>

typedef struct {
	double x, y;
} RMMercatorPoint;

typedef struct {
	double width, height;
} RMMercatorSize;

typedef struct {
	RMMercatorPoint origin;
	RMMercatorSize size;
} RMMercatorRect;

RMMercatorPoint RMScaleMercatorPointAboutPoint(RMMercatorPoint point, float factor, RMMercatorPoint pivot);
RMMercatorRect  RMScaleMercatorRectAboutPoint (RMMercatorRect rect,   float factor, RMMercatorPoint pivot);
RMMercatorPoint RMTranslateMercatorPointBy    (RMMercatorPoint point, RMMercatorSize delta);
RMMercatorRect  RMTranslateMercatorRectBy     (RMMercatorRect rect,   RMMercatorSize delta);
