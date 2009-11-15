//
//  RMLayerSet.m
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

#import "RMLayerCollection.h"
#import "RMMapContents.h"
#import "RMMercatorToScreenProjection.h"

@implementation RMLayerCollection

- (id)initForContents: (RMMapContents *)_contents
{
	if (![super init])
		return nil;

	sublayers = [[NSMutableArray alloc] init];
	mapContents = _contents;
	self.masksToBounds = YES;
	return self;
}

- (void) dealloc 
{
	[sublayers release];
	sublayers = nil;
	mapContents = nil;
	[super dealloc];
}


- (void)correctScreenPosition: (CALayer *)layer
{
	if ([layer conformsToProtocol:@protocol(RMMovingMapLayer)])
	{
		// Kinda ugly.
		CALayer<RMMovingMapLayer>* layer_with_proto = (CALayer<RMMovingMapLayer>*)layer;
		if(layer_with_proto.enableDragging){
			RMProjectedPoint location = [layer_with_proto projectedLocation];
			layer_with_proto.position = [[mapContents mercatorToScreenProjection] projectXYPoint:location];
		}
	}
}


- (void)setSublayers: (NSArray*)array
{
	for (CALayer *layer in array)
	{
		[self correctScreenPosition:layer];
	}
@synchronized(sublayers) {	
	[sublayers removeAllObjects];
	[sublayers addObjectsFromArray:array];
	[super setSublayers:array];
}
}

- (void)addSublayer:(CALayer *)layer
{
@synchronized(sublayers) {
	[self correctScreenPosition:layer];
	[sublayers addObject:layer];
	[super addSublayer:layer];
}
}

- (void)removeSublayer:(CALayer *)layer
{
	@synchronized(sublayers) {
		[sublayers removeObject:layer];
		[layer removeFromSuperlayer];
	}
}

- (void)removeSublayers:(NSArray *)layers
{
	@synchronized(sublayers) {
		for(CALayer *aLayer in layers)
		{
			[sublayers removeObject:aLayer];
			[aLayer removeFromSuperlayer];
		}
	}
}

- (void)insertSublayer:(CALayer *)layer above:(CALayer *)siblingLayer
{
@synchronized(sublayers) {
	[self correctScreenPosition:layer];
	NSUInteger index = [sublayers indexOfObject:siblingLayer];
	[sublayers insertObject:layer atIndex:index + 1];
	[super insertSublayer:layer above:siblingLayer];
}
}

- (void)insertSublayer:(CALayer *)layer below:(CALayer *)siblingLayer
{
@synchronized(sublayers) {
	[self correctScreenPosition:layer];
	NSUInteger index = [sublayers indexOfObject:siblingLayer];
	[sublayers insertObject:layer atIndex:index];
	[super insertSublayer:layer below:siblingLayer];
}
}

- (void)insertSublayer:(CALayer *)layer atIndex:(unsigned)index
{
@synchronized(sublayers) {
	[self correctScreenPosition:layer];
	[sublayers insertObject:layer atIndex:index];

	/// \bug TODO: Fix this.
	[super addSublayer:layer];	
}
}

/*
- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
- (void)removeSublayer:(RMMapLayer*) layer;
 */

- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint
{
	/// \bug TODO: Test this. Does it work?
	[self correctPositionOfAllSublayers];
}

- (void)moveBy: (CGSize) delta
{
	@synchronized(sublayers) {
		for (id layer in sublayers)
		{
			if ([layer respondsToSelector:@selector(moveBy:)])
				[layer moveBy:delta];

			// if layer moves on and offscreen...
		}
	}
}

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center
{
@synchronized(sublayers) {
	for (id layer in sublayers)
	{
		if ([layer respondsToSelector:@selector(zoomByFactor:near:)])
			[layer zoomByFactor:zoomFactor near:center];
	}
}
}

- (void) correctPositionOfAllSublayers
{
@synchronized(sublayers) {
	for (id layer in sublayers)
	{
		[self correctScreenPosition:layer];
	}
}
}

- (BOOL) hasSubLayer:(CALayer *)layer
{
	return [sublayers containsObject:layer];
}

@end
