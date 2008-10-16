//
//  RMMarker.m
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMarker.h"

@implementation RMMarker

- (id) initWithCGImage: (CGImageRef) image
{
	if (![super init])
		return nil;
	
	self.contents = (id)image;
	
	return self;
}

- (id) initWithUIImage: (UIImage*) image
{
	return [self initWithCGImage: [image CGImage]];
}

@end
