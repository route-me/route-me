//
//  RMFoundation.h
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

/*! \struct RMProjectedPoint 
 \brief coordinates, in projected meters, paralleling CGPoint */
typedef struct {
	double easting, northing;
} RMProjectedPoint;

/*! \struct RMProjectedSize 
 \brief width/height struct, in projected meters, paralleling CGSize */
typedef struct {
	double width, height;
} RMProjectedSize;

/*! \struct RMProjectedRect 
 \brief location and size, in projected meters, paralleling CGRect */
typedef struct {
	RMProjectedPoint origin;
	RMProjectedSize size;
} RMProjectedRect;

RMProjectedPoint RMScaleProjectedPointAboutPoint (RMProjectedPoint point, float factor, RMProjectedPoint pivot);
RMProjectedRect  RMScaleProjectedRectAboutPoint(RMProjectedRect rect,   float factor, RMProjectedPoint pivot);
RMProjectedPoint RMTranslateProjectedPointBy (RMProjectedPoint point, RMProjectedSize delta);
RMProjectedRect  RMTranslateProjectedRectBy (RMProjectedRect rect,   RMProjectedSize delta);

RMProjectedPoint  RMMakeProjectedPoint (double easting, double northing);
RMProjectedRect  RMMakeProjectedRect (double easting, double northing, double width, double height);

