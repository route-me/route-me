//
//  Projection.m
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Projection.h"
#import "proj_api.h"

@implementation Projection

@synthesize internalProjection;

-(id) initWithString: (NSString*)params
{
	if (![super init])
		return nil;
	
	internalProjection = pj_init_plus([params UTF8String]);
	if (internalProjection == NULL)
	{
		NSLog(@"Unhandled error creating projection. String is %@", params);
		[self dealloc];
		return nil;
	}
	
	return self;
}

-(id) init
{
	return [self initWithString:@"+proj=latlong +ellps=WGS84"];
}

-(void) dealloc
{
	if (internalProjection)
		pj_free(internalProjection);
	
	[super dealloc];
}

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point
{
	projUV uv = {
		point.longitude * DEG_TO_RAD,
		point.latitude * DEG_TO_RAD
	};
	
	projUV result = pj_fwd(uv, internalProjection);
	
	CLLocationCoordinate2D result_point = {
		result.v,
		result.u,
	};
	
	return result_point;
}

-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point
{
	projUV uv = {
		point.latitude,
		point.longitude
	};
	
	projUV result = pj_inv(uv, internalProjection);
	
	CLLocationCoordinate2D result_point = {
		result.u * RAD_TO_DEG,
		result.v * RAD_TO_DEG
	};
	
	return result_point;
}

static Projection* _google = nil;
static Projection* _latlong = nil;

+(Projection*) EPSGGoogle
{
	if (_google)
	{
		return _google;
	}
	else
	{
		_google = [[Projection alloc] initWithString:@"+title= Google Mercator EPSG:900913 +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"];	
		return _google;
	}
}

+(Projection*) EPSGLatLong;
{
	if (_latlong)
	{
		return _latlong;
	}
	else
	{
		_latlong = [[Projection alloc] initWithString:@"+proj=latlong +ellps=WGS84"];
		return _latlong;
	}
}

@end
