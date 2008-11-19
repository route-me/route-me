/*
 *  RMLatLong.h
 *  MapView
 *
 *  Created by Joseph Gentle on 22/09/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _RMLATLONG_H_
#define _RMLATLONG_H_

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <CoreLocation/CoreLocation.h>

typedef struct {
	CLLocationCoordinate2D northWest;
	CLLocationCoordinate2D southEast;
} RMLatLongBounds;

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

typedef CLLocationCoordinate2D RMLatLong;

#endif