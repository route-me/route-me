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

- (id<CAAction>)actionForKey:(NSString *)key
{
	if ([key isEqualToString:@"position"]
		|| [key isEqualToString:@"bounds"])
		return nil;
	
	else return [super actionForKey:key];
}

- (void)moveBy: (CGSize) delta
{
	self.position = RMTranslateCGPointBy(self.position, delta);
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) pivot
{
	self.position = RMScaleCGPointAboutPoint(self.position, zoomFactor, pivot);
	self.bounds = RMScaleCGRectAboutPoint(self.bounds, zoomFactor, self.anchorPoint);
}

@end
