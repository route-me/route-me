//
//  Mercator.m
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Mercator.h"
#import "Projection.h"

@implementation Mercator

+ (CLLocationCoordinate2D) mercatorAsCLLocation: (MercatorPoint) merc
{
	CLLocationCoordinate2D point;
	point.latitude = merc.y;
	point.longitude = merc.x;
	return point;
}

+ (MercatorPoint) cLlocationAsMercator: (CLLocationCoordinate2D) coordinate
{
	MercatorPoint point;
	point.x = coordinate.longitude;
	point.y = coordinate.latitude;
	return point;
}

+ (CLLocationCoordinate2D) toLatLong: (MercatorPoint) coordinate
{
	return [[Projection EPSGGoogle] projectInverse:[Mercator mercatorAsCLLocation:coordinate]];
}

+ (MercatorPoint) toMercator: (CLLocationCoordinate2D) coordinate
{
	return [Mercator cLlocationAsMercator:[[Projection EPSGGoogle] projectForward:coordinate]];
}

@end
