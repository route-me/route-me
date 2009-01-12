//
//  BoundBox.m
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import "BoundBox.h"
#import "MapTools.h"

@implementation BoundBox

@synthesize northWestCoordinates;
@synthesize southEastCoordinates;

- (id)initWithCoordinatesNorthWest:(MapCoordinates*) initNorthWestCoordinates
						 SouthEast:(MapCoordinates*) initSouthEastCoordinates {
	assert(initNorthWestCoordinates != 0);
	assert(initSouthEastCoordinates != 0);
	assert([initNorthWestCoordinates latitude] >
		   [initSouthEastCoordinates latitude]);
	
	northWestCoordinates = [[MapCoordinates alloc] 
							initWithLatitude:[initNorthWestCoordinates latitude] 
							Longitude:[initNorthWestCoordinates longitude]];
	
	southEastCoordinates = [[MapCoordinates alloc] 
							initWithLatitude:[initSouthEastCoordinates latitude] 
							Longitude:[initSouthEastCoordinates longitude]];
	
	return self;
}

- (double) northLatitude {
	return [northWestCoordinates latitude];
}

- (double) westLongitude {
	return [northWestCoordinates longitude];
}

- (double) southLatitude {
	return [southEastCoordinates latitude];
}

- (double) eastLongitude {
	return [southEastCoordinates longitude];
}

- (void)dealloc {
	[northWestCoordinates release];
	[southEastCoordinates release];
	[super dealloc];
}

@end
