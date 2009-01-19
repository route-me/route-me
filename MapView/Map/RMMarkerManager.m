//
//  RMMarkerManager.m
//  MapView
//
//  Created by olivier on 11/5/08.
//  Copyright 2008 NA. All rights reserved.
//

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

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 
#pragma mark Adding / Removing / Displaying Markers

- (void) addMarker: (RMMarker*)marker
{
	[[contents overlay] addSublayer:marker];
}

- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[marker setLocation:[[contents projection]latLongToPoint:point]];
	[self addMarker: marker];
}

- (void) addDefaultMarkerAt: (CLLocationCoordinate2D)point
{
	RMMarker *marker = [[RMMarker alloc] initWithKey:RMMarkerRedKey];
	[self addMarker:marker AtLatLong:point];
	[marker release];
}

- (void) removeMarkers
{
	[[contents overlay] setSublayers:[NSArray arrayWithObjects:nil]]; 
}

- (void) hideAllMarkers 
{
	[[contents overlay] setHidden:YES];
}

- (void) unhideAllMarkers
{
	[[contents overlay] setHidden:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark 
#pragma mark Marker information

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

- (CGPoint) getMarkerScreenCoordinate: (RMMarker *)marker
{
	return [[contents mercatorToScreenProjection] projectXYPoint:[marker location]];
}

- (CLLocationCoordinate2D) getMarkerCoordinate2D: (RMMarker *) marker
{
	return [contents pixelToLatLong:[self getMarkerScreenCoordinate:marker]];
}

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
