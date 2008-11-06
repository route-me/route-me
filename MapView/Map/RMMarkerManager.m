//
//  RMMarkerManager.m
//  MapView
//
//  Created by olivier on 11/5/08.
//  Copyright 2008 NA. All rights reserved.
//

#import "RMMarkerManager.h"
#import "RMMercatorToScreenProjection.h"

@implementation RMMarkerManager

@synthesize contents;

- (id)initWithContents:(RMMapContents *)mapContents
{
	if (![super init])
		return nil;
	
	contents = mapContents;

	return self;
}

- (void) addMarker: (RMMarker*)marker
{
	[[contents overlay] addSublayer:marker];
}

- (void) addMarker: (RMMarker*)marker AtLatLong:(CLLocationCoordinate2D)point
{
	[marker setLocation:[contents latLongToPoint:point]];
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

- (NSArray *)getMarkers
{
	return [[contents overlay] sublayers];
}

- (void) removeMarker:(RMMarker *)marker
{
	[marker removeFromSuperlayer];
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
	NSMutableArray *markers;
	markers  = [NSMutableArray array];
	CGRect rect = [[contents mercatorToScreenProjection] screenBounds];
	
	NSArray *allMarkers = [self getMarkers];
	
	NSEnumerator *markerEnumerator = [allMarkers objectEnumerator];
	RMMarker *aMarker;
	
	while (aMarker = (RMMarker *)[markerEnumerator nextObject])
	{
		CGPoint markerCoord = [self getMarkerScreenCoordinate:aMarker];
		
		if( ((markerCoord.x > rect.origin.x) && (markerCoord.y > rect.origin.y)) &&
		   ((markerCoord.x < (rect.origin.x + rect.size.width)) && (markerCoord.y < (rect.origin.y + rect.size.height))))
		{
			[markers addObject:aMarker];
		}
	}
	
	return markers;
}

@end
