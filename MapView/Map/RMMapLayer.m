//
//  Layer.m
//  MapView
//
//  Created by Joseph Gentle on 22/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMMapLayer.h"

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
	
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	
}

@end
