//
//  MapCoordinates.m
//  freemap-iphone
//
//  Created by Michel Barakat on 8/31/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "MapCoordinates.h"

@implementation MapCoordinates

@synthesize latitude;
@synthesize longitude;

- (id)initWithLatitude:(double)initLatitude Longitude:(double)initLongitude {
	[self setLatitude:initLatitude];
	[self setLongitude:initLongitude];
	
	return self;
}

- (void)setLatitude:(double)newLatitude {
	// This limit is equivalent to arctan(sinh(PI)). Using it on latitude edges
	// causes the map to be a perfect square.
	static double maxLatitude = 85.051129;
	
	if (newLatitude > maxLatitude) {
		NSLog(@"Latitude %f out of bounds, reduced to %f", newLatitude,
			  maxLatitude);
		newLatitude = maxLatitude;
	} else if (newLatitude < -maxLatitude) {
		NSLog(@"Latitude %f out of bounds, reduced to %f", newLatitude,
			  -maxLatitude);
		newLatitude = -maxLatitude;
	}
	latitude = newLatitude;
}

- (void)setLongitude:(double)newLongitude {
	static const double maxLongitude = 180.0;
  static const double fullCycle = 360.0;
  
  // Equivalent to newLongitude % 360.0
	newLongitude = newLongitude - ((int)(newLongitude / fullCycle) * fullCycle);
  
  // Keep longitude in [-180.0 180.0] range.
	if (newLongitude > maxLongitude) {
    newLongitude = newLongitude - fullCycle;
  } else if (newLongitude < -maxLongitude) {
    newLongitude = newLongitude + fullCycle;
  }
	longitude = newLongitude;
}

@end
