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

bool RMProjectedRectInterectsProjectedRect(RMProjectedRect rect1, RMProjectedRect rect2)
{
	double minEasting1 = rect1.origin.easting;
	double maxEasting1 = rect1.origin.easting + rect1.size.width;
	double minNorthing1 = rect1.origin.northing;
	double maxNorthing1 = rect1.origin.northing + rect1.size.height;

	double minEasting2 = rect2.origin.easting;
	double maxEasting2 = rect2.origin.easting + rect2.size.width;
	double minNorthing2 = rect2.origin.northing;
	double maxNorthing2 = rect2.origin.northing + rect2.size.height;

	return ((minEasting1 <= minEasting2 && minEasting2 <= maxEasting1) || (minEasting2 <= minEasting1 && minEasting1 <= maxEasting2))
		&& ((minNorthing1 <= minNorthing2 && minNorthing2 <= maxNorthing1) || (minNorthing2 <= minNorthing1 && minNorthing1 <= maxNorthing2));
	
}

bool RMProjectedSizeEqualToProjectedSize(RMProjectedSize size1, RMProjectedSize size2) {
    return ((size1.width == size2.width) && (size1.height == size2.height));
}

bool RMProjectedRectEqualToProjectedRect(RMProjectedRect rect1, RMProjectedRect rect2) {
    return (RMProjectedPointEqualToProjectedPoint(rect1.origin, rect2.origin) && RMProjectedSizeEqualToProjectedSize(rect1.size, rect2.size));
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

RMProjectedSize RMMakeProjectedSize(double width, double height) {
    RMProjectedSize size = {
        width, height
    };
    return size;
}

RMProjectedRect  RMMakeProjectedRect (double easting, double northing, double width, double height)
{
	RMProjectedRect rect = {
		{easting, northing},
		{width, height}
	};
	
	return rect;
}

double RMProjectedRectGetMidEasting(RMProjectedRect rect) {
    return (rect.origin.easting + rect.size.width / 2);
}

double RMProjectedRectGetMidNorthing(RMProjectedRect rect){
    return (rect.origin.northing + rect.size.height / 2);
}



