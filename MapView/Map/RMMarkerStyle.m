//
//  RMMarkerStyle.m
//  MapView
//
//  Created by Hauke Brandes on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMarkerStyle.h"


@implementation RMMarkerStyle

@synthesize markerIcon;
@synthesize anchorPoint;

+ (RMMarkerStyle*) markerStyleWithIcon: (UIImage*) image
{
	return [[[RMMarkerStyle alloc] initWithIcon: image] autorelease];
}

- (RMMarkerStyle*) initWithIcon: (UIImage*) _image
{
	self = [super init];
	if (self==nil) return nil;
	
	self.markerIcon = _image;
	anchorPoint = CGPointMake(0.5, 1.0);
	
	return self;
}

- (void) dealloc
{
	[markerIcon release];
	[super dealloc];
}

@end
