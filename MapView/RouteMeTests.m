//
//  RouteMeTests.m
//  MapView
//
//  Created by Hal Mueller on 4/6/09.
//  Copyright 2009 Route-Me Contributors. All rights reserved.
//

#import "RouteMeTests.h"
#import "RMMapView.h"
#import "RMCloudMadeMapSource.h"
#import "RMGeoHash.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"

@implementation RouteMeTests

- (void)setUp {
    [super setUp];

	CGRect appRect = [[UIScreen mainScreen] applicationFrame];
	contentView = [[UIView alloc] initWithFrame:appRect];
	contentView.backgroundColor = [UIColor greenColor];
	
	NSLog(@"%@", [UIScreen mainScreen]);
	initialCenter.latitude = 66.44;
	initialCenter.longitude = -178.0;
	
	mapView = [[RMMapView alloc] initWithFrame:CGRectMake(10,20,200,300)
								  WithLocation:initialCenter];
	NSLog(@"contentView %@ mapView %@", contentView, mapView);
	[contentView addSubview:mapView];
}

-(void)tearDown {
    [mapView release]; mapView = nil;
	[super tearDown];
}

- (void)testObjectCreation 
{
	
	STAssertNotNil((mapView = [[RMMapView alloc] init]), @"mapView alloc/init failed");
	STAssertNoThrow([mapView release], @"mapView release failed");
	mapView = nil;
	
	id myTilesource;
	STAssertNotNil((myTilesource = [[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d6934" styleNumber:999]),
				   @"tilesource creation failed");
	STAssertNoThrow([myTilesource release], @"tilesource release failed");
	STAssertNil((myTilesource = [[RMCloudMadeMapSource alloc] initWithAccessKey:nil styleNumber:999]),
				@"empty CloudMade key does not trigger error");
	STAssertNoThrow([myTilesource release], @"tilesource release failed");
	STAssertThrows((myTilesource = [[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d693" styleNumber:999]),
				@"bogus CloudMade key does not trigger error");
	STAssertNoThrow([myTilesource release], @"tilesource release failed");
}

- (void)testGeohashing 
{
	CLLocationCoordinate2D location1, location2;
	location1.latitude = 38.89;
	location1.longitude = -77.0;
	STAssertEqualStrings([RMGeoHash fromLocation:location1 withPrecision:6], @"dqcjr2", @"6-digit geohash location1 failed");
	STAssertEqualStrings([RMGeoHash fromLocation:location1 withPrecision:4], @"dqcj", @"4-digit geohash location1 failed");
	
	location2.latitude = 38.89;
	location2.longitude = -77.1;
	STAssertEqualStrings([RMGeoHash fromLocation:location2 withPrecision:6], @"dqcjjx", @"geohash location2 failed");
	STAssertEqualStrings([RMGeoHash fromLocation:location2 withPrecision:4], @"dqcj", @"4-digit geohash location1 failed");
											  
}

- (void)testProgrammaticViewCreation
{
	STAssertNotNil(mapView, @"mapview creation failed");
	STAssertNotNil([mapView contents], @"mapView contents should not be nil");
	NSLog(@"%@", [mapView contents]);
	
}

- (void)testMarkerCreation
{
	CLLocationCoordinate2D markerPosition;
	NSUInteger nRows = 1;
	NSUInteger nColumns = 8;
	double columnSpacing = 2.0;
	
	UIImage *markerImage = [UIImage imageNamed:@"marker-red.png"];
	STAssertNotNil(markerImage, @"testMarkerCreation marker image did not load");
	markerPosition.latitude = initialCenter.latitude - ((nRows - 1)/2.0 * columnSpacing);
	int i, j;
	for (i = 0; i < nRows; i++) {
		markerPosition.longitude = initialCenter.longitude - ((nColumns - 1)/2.0 * columnSpacing);
		for (j = 0; j < nColumns; j++) {
			markerPosition.longitude += columnSpacing;
			NSLog(@"%f %f", markerPosition.latitude, markerPosition.longitude);
			RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:markerImage];
			STAssertNotNil(newMarker, @"testMarkerCreation marker creation failed");
#ifdef DEBUG
			[newMarker setLatlon:markerPosition];
#endif
			[mapView.contents.markerManager addMarker:newMarker
			 AtLatLong:markerPosition];
		}
		markerPosition.latitude += columnSpacing;
	}
	
#ifdef DEBUG
	RMMarkerManager *mangler = [[mapView contents] markerManager];
	
	for (RMMarker *theMarker in [mangler getMarkers]) {
		CGPoint screenPosition = [mangler getMarkerScreenCoordinate:theMarker];
		NSLog(@"%@ %3.1f %3.1f %f %f", theMarker, 
			  theMarker.latlon.latitude, theMarker.latlon.longitude,
			  screenPosition.y, screenPosition.x);
	}
#endif
}

- (void)testMarkerCoordinates
{
	CLLocationCoordinate2D markerPosition;
	
	NSUInteger nColumns = 8;
	double columnSpacing = 2.0;

	UIImage *markerImage = [UIImage imageNamed:@"marker-red.png"];
	markerPosition.latitude = initialCenter.latitude;
	markerPosition.longitude = initialCenter.longitude - ((nColumns - 1)/2.0 * columnSpacing);
	int j;
	NSMutableArray *testMarkers = [NSMutableArray arrayWithCapacity:nColumns];
	for (j = 0; j < nColumns; j++) {
		markerPosition.longitude += columnSpacing;
		NSLog(@"%f %f", markerPosition.latitude, markerPosition.longitude);
		RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:markerImage];
		[testMarkers addObject:newMarker];
#ifdef DEBUG
		[newMarker setLatlon:markerPosition];
#endif
		[mapView.contents.markerManager addMarker:newMarker
		 AtLatLong:markerPosition];
	}
	STAssertGreaterThan(columnSpacing, 0.0, @"this test requires positive columnSpacing");
#ifdef DEBUG
	RMMarkerManager *mangler = [[mapView contents] markerManager];
	
	[[mapView contents] moveBy:CGSizeMake(-5.0, 0.0)];
	for (j = 1; j < nColumns; j++) {
		RMMarker *leftMarker = [testMarkers objectAtIndex:j - 1];
		RMMarker *rightMarker = [testMarkers objectAtIndex:j];
		CGPoint leftScreenPosition = [mangler getMarkerScreenCoordinate:leftMarker];
		CGPoint rightScreenPosition = [mangler getMarkerScreenCoordinate:rightMarker];
		STAssertLessThan(leftScreenPosition.x, rightScreenPosition.x, 
						 @"screen position calculation failed: left (%f, %f) right (%f, %f) mapped to left (%f, %f) right (%f, %f)",
						 leftMarker.latlon.longitude, leftMarker.latlon.latitude,
						 rightMarker.latlon.longitude, rightMarker.latlon.latitude,
						 leftScreenPosition.x, leftScreenPosition.y, rightScreenPosition.x, rightScreenPosition.y);
	}
#endif
	
}
@end
