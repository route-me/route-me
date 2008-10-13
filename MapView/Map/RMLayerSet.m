//
//  RMLayerSet.m
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLayerSet.h"


@implementation RMLayerSet

- (id) init
{
	if (![super init])
		return nil;
	
	container = [[CALayer alloc] init];
	
	
	return self;
}

/*
- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
- (void)removeSublayer:(RMMapLayer*) layer;

- (void)moveToMercator: (RMMercatorPoint)mercator;
*/
- (void)moveBy: (CGSize) delta
{
	for (id layer in layers)
	{
		if ([layer respondsToSelector:@selector(moveBy:)])
			[layer moveBy:delta];
	}
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	for (id layer in layers)
	{
		if ([layer respondsToSelector:@selector(zoomByFactor:Near:)])
			[layer zoomByFactor:zoomFactor Near:center];
	}
}

-(CALayer*) layer
{
	return container;
}

-(void) drawRect: (CGRect)rect
{
	NSLog(@"Map layers not currently supported using quartz renderer");
}

@end
