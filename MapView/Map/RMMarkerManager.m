//
//  RMMarkerManager.m
//
// Copyright (c) 2008, Route-Me Contributors
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
#import "RMLayerSet.h"

@implementation RMMarkerManager

@synthesize contents;

- (id)initWithContents:(RMMapContents *)mapContents
{
	if (![super init])
		return nil;
	
	contents = mapContents;

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

- (void) addMarker: (RMMarker*)marker
{
	[[contents overlay] addSublayer:marker];
}

/// \bug should return the marker
- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[marker setLocation:[[contents projection]latLongToPoint:point]];
	[self addMarker: marker];
}

/// \bug should return the marker
- (void) addDefaultMarkerAt: (CLLocationCoordinate2D)point
{
	RMMarker *marker = [[RMMarker alloc] initWithKey:RMMarkerRedKey];
	[self addMarker:marker AtLatLong:point];
	[marker release];
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

/// \deprecated violates Objective-C naming rules
- (NSArray *)getMarkers
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

/// \deprecated violates Objective-C naming rules
- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker
{
	return [[contents mercatorToScreenProjection] projectXYPoint:[marker location]];
}

/// \deprecated violates Objective-C naming rules, confusing name
- (CLLocationCoordinate2D) getMarkerCoordinate2D: (RMMarker *) marker
{
	return [contents pixelToLatLong:[self getMarkerScreenCoordinate:marker]];
}

/// \deprecated violates Objective-C naming rules
- (NSArray *) getMarkersForScreenBounds
{
	NSMutableArray *markersInScreenBounds = [NSMutableArray array];
	CGRect rect = [[contents mercatorToScreenProjection] screenBounds];
	
	for (RMMarker *marker in [self getMarkers]) {
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
	
	CGPoint markerCoord = [self getMarkerScreenCoordinate:marker];
	
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
	if (marker != nil && [[self getMarkers] indexOfObject:marker] != NSNotFound) {
		return YES;
	}
	return NO;
}

- (void) moveMarker:(RMMarker *)marker AtLatLon:(RMLatLong)point
{
	[marker setLocation:[[contents projection]latLongToPoint:point]];
	[marker setPosition:[[contents mercatorToScreenProjection] projectXYPoint:[[contents projection] latLongToPoint:point]]];
}

- (void) moveMarker:(RMMarker *)marker AtXY:(CGPoint)point
{
	[marker setLocation:[[contents mercatorToScreenProjection] projectScreenPointToXY:point]];
	[marker setPosition:point];
}

@end
