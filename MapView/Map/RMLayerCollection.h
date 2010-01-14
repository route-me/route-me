//
//  RMLayerSet.h
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

#import <Foundation/Foundation.h>
#import "RMFoundation.h"
#import "RMMapLayer.h"

@class RMMapRenderer;
@class RMMapContents;

/*! Appears to be some sort of interface between RMMapContents and markers.
 
 \bug lots of arbitrary-appearing \@synchronized blocks. Old mailing list traffic 
 claims they're needed, but no one seems to know why. If the #set ivar needs to be guarded,
 should be done by \@synchronized(self) and not \@synchronized(sublayers). Maybe the guarding
 is needed because of Core Animation thread interactions.
 */
@interface RMLayerCollection : RMMapLayer
{
	/// The actual collection of all sublayers, including those offscreen.
	/// It is ordered back to front.
	NSMutableArray *sublayers;
	
	/// Backpointer to map; we need this reference so we can access the projections...
	RMMapContents *mapContents;
	CGAffineTransform rotationTransform;
}

- (id)initForContents: (RMMapContents *)contents;

//- (void)insertSublayer:(RMMapLayer*) layer below:(RMMapLayer*)sibling;
//- (void)insertSublayer:(RMMapLayer*) layer above:(RMMapLayer*)sibling;
//- (void)removeSublayer:(RMMapLayer*) layer;

- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint;
- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)removeSublayer:(CALayer *)layer;
- (void)removeSublayers:(NSArray *)layers;
/// (guess) recompute the screen coordinates for the sublayers (map markers, paths) 
/// \deprecated name will change after 0.5
- (void) correctPositionOfAllSublayers;
- (BOOL) hasSubLayer:(CALayer *)layer;
- (void) setRotationOfAllSublayers:(float) angle;
//-(void) drawRect: (CGRect)rect;
//-(CALayer*) layer;

@end
