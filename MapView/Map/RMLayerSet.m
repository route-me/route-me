//
//  RMLayerSet.m
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLayerSet.h"


@implementation RMLayerSet

- (id)initForContents: (RMMapContents *)_contents
{
	if (![super init])
		return nil;

	set = [[NSMutableArray alloc] init];
	mapContents = _contents;
	
	return self;
}

- (void)setSublayers: (NSArray*)array
{
	[set removeAllObjects];
	[set addObjectsFromArray:array];
	[super setSublayers:array];
}

- (void)addSublayer:(CALayer *)layer
{
	[set addObject:layer];
	[super addSublayer:layer];
}

- (void)insertSublayer:(CALayer *)layer above:(CALayer *)siblingLayer
{
	int index = [set indexOfObject:siblingLayer];
	[set insertObject:layer atIndex:index + 1];
	[super insertSublayer:layer above:siblingLayer];
}

- (void)insertSublayer:(CALayer *)layer below:(CALayer *)siblingLayer
{
	int index = [set indexOfObject:siblingLayer];
	[set insertObject:layer atIndex:index];
	[super insertSublayer:layer below:siblingLayer];
}

- (void)insertSublayer:(CALayer *)layer atIndex:(unsigned)index
{
	[set insertObject:layer atIndex:index];

	// TODO: Fix this.
	[super addSublayer:layer];	
}

/*
- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
- (void)removeSublayer:(RMMapLayer*) layer;
 */

- (void)moveToMercator: (RMMercatorPoint)mercator
{
	// TODO: Me
}

- (void)moveBy: (CGSize) delta
{
	for (id layer in set)
	{
		if ([layer respondsToSelector:@selector(moveBy:)])
			[layer moveBy:delta];

		// if layer moves on and offscreen...
	}
}

- (void)zoomByFactor: (float) zoomFactor Near:(CGPoint) center
{
	for (id layer in set)
	{
		if ([layer respondsToSelector:@selector(zoomByFactor:Near:)])
			[layer zoomByFactor:zoomFactor Near:center];
	}
}

@end
