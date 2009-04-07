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

@implementation RouteMeTests

//- (void)setUp {
//    [super setUp]
//}
//
//-(void)tearDown {
//    [super tearDown];
//}

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

@end
