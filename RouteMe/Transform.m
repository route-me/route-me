//
//  Transform.m
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Transform.h"
#import "Projection.h"

@implementation Transform

-(id) initFrom: (Projection*)_source To: (Projection*)_dest
{
	if (![super init])
		return nil;
	
	source = _source;
	destination = _dest;
	
	is_source_latlong = pj_is_latlong(source.internalProjection);
	is_dest_latlong = pj_is_latlong(destination.internalProjection);
	
	if (source == nil || destination == nil)
	{
		[self dealloc];
		return nil;
	}
	
	return self;
}

-(void) dealloc
{
	[source release];
	[destination release];
	
	[super dealloc];
}

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point AtZoom: (double)z
{
	double zo = z;
	
	if (is_source_latlong)
	{
		point.latitude *= DEG_TO_RAD;
		point.longitude *= DEG_TO_RAD;
	}
	
	int retval = pj_transform(source.internalProjection, destination.internalProjection, 1, 0,
				 &point.longitude, &point.latitude, &z);
	
	if (is_dest_latlong)
	{
		point.latitude *= RAD_TO_DEG;
		point.longitude *= RAD_TO_DEG;
	}
	
	if (z != zo)
	{
		NSLog(@"z changed....");
	}
	if (retval != 0)
	{	// This should be fixed to handle these errors...
		NSLog(@"Error occured during pj_transform: %s", pj_strerrno(retval));
	}
	
	return point;
}

-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point AtZoom: (double)z
{
	pj_transform(destination.internalProjection, source.internalProjection, 1, 0,
				 &point.longitude,&point.latitude,&z);
	
	return point;
}

@end
