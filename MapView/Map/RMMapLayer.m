//
//  Layer.m
//  MapView
//
//  Created by Joseph Gentle on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapLayer.h"
#import "RMPixel.h"

@implementation RMMapLayer

- (id) init
{
	if (![super init])
		return nil;
	
	return self;
}

- (id)initWithLayer:(id)layer
{
	if (![super initWithLayer:layer])
		return nil;
	
	return self;
}

- (void)moveBy: (CGSize) delta
{
	self.position = RMTranslateCGPointBy(self.position, delta);
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	CGRect currentRect = CGRectMake(self.position.x, self.position.y, self.bounds.size.width, self.bounds.size.height);
	CGRect newRect = RMScaleCGRectAboutPoint(currentRect, zoomFactor, center);
	self.position = newRect.origin;
	self.bounds = CGRectMake(0, 0, newRect.size.width, newRect.size.height);
}

@end
