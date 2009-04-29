//
//  RMLatLong.h
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

#ifndef _RMLATLONG_H_
#define _RMLATLONG_H_

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <CoreLocation/CoreLocation.h>
#import "RMGlobalConstants.h"

/*! \struct RMSphericalTrapezium
 
 \brief Specifies a spherical trapezium by northwest and southeast corners, each given as CLLocationCoordinate2D, similar to specifying the corners of a box.
 
 A spherical trapezium is the surface of a sphere or ellipsoid bounded by two meridians and two parallels. Note that in almost all cases, the lengths of the northern and southern sides of the box are different.
 */
typedef struct {
	CLLocationCoordinate2D northeast;
	CLLocationCoordinate2D southwest;
} RMSphericalTrapezium;

#else

/* From CoreLocation by Apple inc. Copyright 2008 Apple Computer, Inc. All rights reserved. */

/*
 *  CLLocationDegrees
 *  
 *  Discussion:
 *    Type used to represent a latitude or longitude coordinate in degrees under the WGS 84 reference
 *    frame. The degree can be positive (North and East) or negative (South and West).  
 */
typedef double CLLocationDegrees;
/*
 *  CLLocationCoordinate2D
 *  
 *  Discussion:
 *    A structure that contains a geographical coordinate.
 *
 *  Fields:
 *    latitude:
 *      The latitude in degrees.
 *    longitude:
 *      The longitude in degrees.
 */
typedef struct {
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
} CLLocationCoordinate2D;

#endif

/*! \struct RMLatLong 
 \brief latitude/longitude of a point, in WGS-84 degrees
 */
typedef CLLocationCoordinate2D RMLatLong;

/// \bug magic numbers
static const double kRMMinLatitude = -kMaxLat;
static const double kRMMaxLatitude = kMaxLat;
static const double kRMMinLongitude = -kMaxLong;
static const double kRMMaxLongitude = kMaxLong;

#endif