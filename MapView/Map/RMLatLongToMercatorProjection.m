//
//  Mercator.m
//  Images
//
//  Created by Joseph Gentle on 21/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLatLongToMercatorProjection.h"
#import "RMMercator.h"
#import "RMProjection.h"

@implementation RMLatLongToMercatorProjection

-(void) testLat: (double) latitude Long:(double) longitude
{
	CLLocationCoordinate2D loc;
	loc.latitude = latitude;
	loc.longitude = longitude;
	RMMercatorPoint merc = [self projectLatLongToMercator:loc];
	
	NSLog(@"ll=%f %f -> %f %f", longitude, latitude, merc.x, merc.y);
}

-(id) initWithProjection: (RMProjection*) _projection
{
	if (![super init])
		return nil;
	
	projection = _projection;
	[projection retain];
	
//	[self testLat:0 Long:0];
//	[self testLat:80 Long:180];
//	[self testLat:-80 Long:180];
//	[self testLat:-80 Long:-180];
//	[self testLat:80 Long:-180];

	return self;
}

-(void) dealloc
{
	[projection release];
	
	[super dealloc];
}

-(CLLocationCoordinate2D) projectMercatorToLatLong: (RMMercatorPoint) coordinate
{
	return [projection projectInverse:[RMLatLongToMercatorProjection mercatorAsCLLocation:coordinate]];
}

-(RMMercatorPoint) projectLatLongToMercator: (CLLocationCoordinate2D) coordinate
{
	return [RMLatLongToMercatorProjection cLlocationAsMercator:[projection projectForward:coordinate]];
}

+(CLLocationCoordinate2D) mercatorAsCLLocation:(RMMercatorPoint) merc
{
	CLLocationCoordinate2D point;
	point.latitude = merc.y;
	point.longitude = merc.x;
	return point;
}

+(RMMercatorPoint) cLlocationAsMercator:(CLLocationCoordinate2D) coordinate
{
	RMMercatorPoint point;
	point.x = coordinate.longitude;
	point.y = coordinate.latitude;
	return point;
}

static RMLatLongToMercatorProjection* _google = nil;

+(RMLatLongToMercatorProjection*) googleProjection
{
	if (_google)
	{
		return _google;
	}
	else
	{
		_google = [[RMLatLongToMercatorProjection alloc] initWithProjection:[RMProjection EPSGGoogle]];
		return _google;
	}
}
@end


/*
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
}*/

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