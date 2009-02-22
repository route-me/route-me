//
//  RMFoundation.c
//
// Copyright (c) 2008, Route-Me Contributors
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
