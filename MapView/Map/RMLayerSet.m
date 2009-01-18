//
//  RMLayerSet.m
//  MapView
//
//  Created by Joseph Gentle on 1/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMLayerSet.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"

@implementation RMLayerSet

- (id)initForContents: (RMMapContents *)_contents
{
	if (![super init])
		return nil;

	set = [[NSMutableArray alloc] init];
	mapContents = _contents;
	self.masksToBounds = YES;
	return self;
}

- (void)correctScreenPosition: (CALayer *)layer
{
	if ([layer conformsToProtocol:@protocol(RMMovingMapLayer)])
	{
		// Kinda ugly.
		CALayer<RMMovingMapLayer>* layer_with_proto = (CALayer<RMMovingMapLayer>*)layer;
		RMXYPoint location = [layer_with_proto location];
		layer_with_proto.position = [[mapContents mercatorToScreenProjection] projectXYPoint:location];
	}
}

- (void)setSublayers: (NSArray*)array
{
	for (CALayer *layer in array)
	{
		[self correctScreenPosition:layer];
	}
@synchronized(set) {	
	[set removeAllObjects];
	[set addObjectsFromArray:array];
	[super setSublayers:array];
}
}

- (void)addSublayer:(CALayer *)layer
{
@synchronized(set) {
	[self correctScreenPosition:layer];
	[set addObject:layer];
	[super addSublayer:layer];
}
}

- (void)insertSublayer:(CALayer *)layer above:(CALayer *)siblingLayer
{
@synchronized(set) {
	[self correctScreenPosition:layer];
	int index = [set indexOfObject:siblingLayer];
	[set insertObject:layer atIndex:index + 1];
	[super insertSublayer:layer above:siblingLayer];
}
}

- (void)insertSublayer:(CALayer *)layer below:(CALayer *)siblingLayer
{
@synchronized(set) {
	[self correctScreenPosition:layer];
	int index = [set indexOfObject:siblingLayer];
	[set insertObject:layer atIndex:index];
	[super insertSublayer:layer below:siblingLayer];
}
}

- (void)insertSublayer:(CALayer *)layer atIndex:(unsigned)index
{
@synchronized(set) {
	[self correctScreenPosition:layer];
	[set insertObject:layer atIndex:index];

	// TODO: Fix this.
	[super addSublayer:layer];	
}
}

/*
- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
- (void)removeSublayer:(RMMapLayer*) layer;
 */

- (void)moveToXYPoint: (RMXYPoint)aPoint
{
	// TODO: Test this. Does it work?
	[self correctPositionOfAllSublayers];
}

- (void)moveBy: (CGSize) delta
{
	@synchronized(set) {
		for (id layer in set)
		{
			if ([layer respondsToSelector:@selector(moveBy:)])
				[layer moveBy:delta];

			// if layer moves on and offscreen...
		}
	}
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
@synchronized(set) {
	for (id layer in set)
	{
		if ([layer respondsToSelector:@selector(zoomByFactor:near:)])
			[layer zoomByFactor:zoomFactor near:center];
	}
}
}

- (void) correctPositionOfAllSublayers
{
@synchronized(set) {
	for (id layer in set)
	{
		[self correctScreenPosition:layer];
	}
}
}

@end
