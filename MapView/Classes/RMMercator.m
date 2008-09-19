//
//  Mercator.m
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMercator.h"
#import "RMProjection.h"

@implementation RMMercator

+ (CLLocationCoordinate2D) mercatorAsCLLocation: (RMMercatorPoint) merc
{
	CLLocationCoordinate2D point;
	point.latitude = merc.y;
	point.longitude = merc.x;
	return point;
}

+ (RMMercatorPoint) cLlocationAsMercator: (CLLocationCoordinate2D) coordinate
{
	RMMercatorPoint point;
	point.x = coordinate.longitude;
	point.y = coordinate.latitude;
	return point;
}

+ (CLLocationCoordinate2D) toLatLong: (RMMercatorPoint) coordinate
{
	return [[RMProjection EPSGGoogle] projectInverse:[RMMercator mercatorAsCLLocation:coordinate]];
}

+ (RMMercatorPoint) toMercator: (CLLocationCoordinate2D) coordinate
{
	return [RMMercator cLlocationAsMercator:[[RMProjection EPSGGoogle] projectForward:coordinate]];
}

+ (RMMercatorPoint) clipPoint: (RMMercatorPoint)point ToBounds: (RMMercatorRect) bounds
{
	if (point.x < bounds.origin.x)
		point.x = bounds.origin.x;
	else if (point.x > (bounds.origin.x + bounds.size.width))
		point.x = bounds.origin.x + bounds.size.width;

	if (point.y < bounds.origin.y)
		point.y = bounds.origin.y;
	else if (point.y > (bounds.origin.y + bounds.size.height))
		point.y = bounds.origin.y + bounds.size.height;
	
	return point;
}

/* Not complete.
+ (MercatorRect) clipRect: (MercatorRect)rect ToBounds: (MercatorRect) bounds
{
	if (rect.origin.x < bounds.origin.x)
	{
		rect.size.width -= bounds.origin.x - rect.origin.x;
		rect.origin.x = bounds.origin.x;
	}
	else if (rect.origin.x > (bounds.origin.x + bounds.size.width))
	{
		rect.origin.x = bounds.origin.x + bounds.size.width;
		rect.size.width = 0;
	}
	if ((rect.origin.x + rect.size.width) > (bounds.origin.x + bounds.size.width))
	{
		rect.size.width -= (rect.origin.x + rect.size.width) - (bounds.origin.x + bounds.size.width);
		rect.origin.x = bounds.origin.x + bounds.size.width;
	}
	
	if (rect.origin.y < bounds.origin.y)
		rect.origin.y = bounds.origin.y;
	else if (rect.origin.y > (bounds.origin.y + bounds.size.height))
		rect.origin.y = bounds.origin.y + bounds.size.height;
	
}*/

@end
