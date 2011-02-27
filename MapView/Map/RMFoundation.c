//
//  RMFoundation.c
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMFoundation.h"

bool RMProjectedPointEqualToProjectedPoint(RMProjectedPoint point1, RMProjectedPoint point2)
{
	return point1.easting == point2.easting && point2.northing == point2.northing;
}

RMProjectedPoint RMScaleProjectedPointAboutPoint(RMProjectedPoint point, float factor, RMProjectedPoint pivot)
{
	point.easting = (point.easting - pivot.easting) * factor + pivot.easting;
	point.northing = (point.northing - pivot.northing) * factor + pivot.northing;
	
	return point;
}

RMProjectedRect  RMScaleProjectedRectAboutPoint (RMProjectedRect rect,   float factor, RMProjectedPoint pivot)
{
	rect.origin = RMScaleProjectedPointAboutPoint(rect.origin, factor, pivot);
	rect.size.width *= factor;
	rect.size.height *= factor;
	
	return rect;
}

RMProjectedPoint RMTranslateProjectedPointBy(RMProjectedPoint point, RMProjectedSize delta)
{
	point.easting += delta.width;
	point.northing += delta.height;
	return point;
}

RMProjectedRect  RMTranslateProjectedRectBy(RMProjectedRect rect,   RMProjectedSize delta)
{
	rect.origin = RMTranslateProjectedPointBy(rect.origin, delta);
	return rect;
}

RMProjectedPoint  RMMakeProjectedPoint (double easting, double northing)
{
	RMProjectedPoint point = {
		easting, northing
	};
	
	return point;
}

RMProjectedRect  RMMakeProjectedRect (double easting, double northing, double width, double height)
{
	RMProjectedRect rect = {
		{easting, northing},
		{width, height}
	};
	
	return rect;
}
