//
//  RMTransform.m
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

#import "proj_api.h"
#import "RMTransform.h"
#import "RMProjection.h"

@implementation RMTransform

-(id) initFrom: (RMProjection*)_source To: (RMProjection*)_dest
{
	if (![super init])
		return nil;
	
	source = [_source retain];
	destination = [_dest retain];
	
	is_source_latlong = pj_is_latlong(source.internalProjection);
	is_dest_latlong = pj_is_latlong(destination.internalProjection);
	
	if (source == nil || destination == nil)
	{
		[self release];
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
		RMLog(@"z changed....");
	}
	if (retval != 0)
	{	// This should be fixed to handle these errors...
		RMLog(@"Error occured during pj_transform: %s", pj_strerrno(retval));
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
