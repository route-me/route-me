//
//  RMMarkerManager.m
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

#import "RMMarkerManager.h"
#import "RMMercatorToScreenProjection.h"
#import "RMProjection.h"
#import "RMLayerCollection.h"

@implementation RMMarkerManager

@synthesize contents;

- (id)initWithContents:(RMMapContents *)mapContents
{
	if (![super init])
		return nil;
	
	contents = mapContents;
	
	rotationTransform = CGAffineTransformIdentity; 
	
	return self;
}

- (void)dealloc
{
	contents = nil;
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 
#pragma mark Adding / Removing / Displaying Markers

/// place the (new created) marker onto the map at projected point and take ownership of it
- (void)addMarker:(RMMarker *)marker atProjectedPoint:(RMProjectedPoint)projectedPoint {
	[marker setAffineTransform:rotationTransform];
	[marker setProjectedLocation:projectedPoint];
	[marker setPosition:[[contents mercatorToScreenProjection] projectXYPoint:projectedPoint]];
	[[contents overlay] addSublayer:marker];
}

/// place the (newly created) marker onto the map and take ownership of it
/// \bug should return the marker
- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[self addMarker:marker atProjectedPoint:[[contents projection] latLongToPoint:point]];
}

/// \bug see http://code.google.com/p/route-me/issues/detail?id=75
/// (halmueller): I am skeptical about interactions of this code with paths
- (void) removeMarkers
{
	[[contents overlay] setSublayers:[NSArray arrayWithObjects:nil]]; 
}

/// \bug this will hide path overlays too?
/// \deprecated syntactic sugar. Might have a place on RMMapView, but not on RMMarkerManager.
- (void) hideAllMarkers 
{
	[[contents overlay] setHidden:YES];
}

/// \bug this will hide path overlays too?
/// \deprecated syntactic sugar. Might have a place on RMMapView, but not on RMMarkerManager.
- (void) unhideAllMarkers
{
	[[contents overlay] setHidden:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 
#pragma mark Marker information

- (NSArray *)markers
{
	return [[contents overlay] sublayers];
}

- (void) removeMarker:(RMMarker *)marker
{
	[[contents overlay] removeSublayer:marker];
}

- (void) removeMarkers:(NSArray *)markers
{
	[[contents overlay] removeSublayers:markers];
}

- (CGPoint) screenCoordinatesForMarker: (RMMarker *)marker
{
	return [[contents mercatorToScreenProjection] projectXYPoint:[marker projectedLocation]];
}

- (CLLocationCoordinate2D) latitudeLongitudeForMarker: (RMMarker *) marker
{
	return [contents pixelToLatLong:[self screenCoordinatesForMarker:marker]];
}

- (NSArray *) markersWithinScreenBounds
{
	NSMutableArray *markersInScreenBounds = [NSMutableArray array];
	CGRect rect = [[contents mercatorToScreenProjection] screenBounds];
	
	for (RMMarker *marker in [self markers]) {
		if ([self isMarker:marker withinBounds:rect]) {
			[markersInScreenBounds addObject:marker];
		}
	}
	
	return markersInScreenBounds;
}

- (BOOL) isMarkerWithinScreenBounds:(RMMarker*)marker
{
	return [self isMarker:marker withinBounds:[[contents mercatorToScreenProjection] screenBounds]];
}

/// \deprecated violates Objective-C naming rules
- (BOOL) isMarker:(RMMarker*)marker withinBounds:(CGRect)rect
{
	if (![self managingMarker:marker]) {
		return NO;
	}
	
	CGPoint markerCoord = [self screenCoordinatesForMarker:marker];
	
	if (   markerCoord.x > rect.origin.x
		&& markerCoord.x < rect.origin.x + rect.size.width
		&& markerCoord.y > rect.origin.y
		&& markerCoord.y < rect.origin.y + rect.size.height)
	{
		return YES;
	}
	return NO;
}

/// \deprecated violates Objective-C naming rules
- (BOOL) managingMarker:(RMMarker*)marker
{
	if (marker != nil && [[self markers] indexOfObject:marker] != NSNotFound) {
		return YES;
	}
	return NO;
}

- (void) moveMarker:(RMMarker *)marker AtLatLon:(RMLatLong)point
{
	[marker setProjectedLocation:[[contents projection]latLongToPoint:point]];
	[marker setPosition:[[contents mercatorToScreenProjection] projectXYPoint:[[contents projection] latLongToPoint:point]]];
}

- (void) moveMarker:(RMMarker *)marker AtXY:(CGPoint)point
{
	[marker setProjectedLocation:[[contents mercatorToScreenProjection] projectScreenPointToXY:point]];
	[marker setPosition:point];
}

- (void)setRotation:(float)angle
{
  rotationTransform = CGAffineTransformMakeRotation(angle); // store rotation transform for subsequent markers

  for (RMMarker *marker in [self markers]) 
  {
	  [marker setAffineTransform:rotationTransform];
  }
}

@end
