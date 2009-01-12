//
//  BoundBox.h
//  freemap-iphone
//
//  Created by Michel Barakat on 10/20/08.
//  Copyright 2008 Høgskolen i Østfold. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapCoordinates.h"

@interface BoundBox : NSObject {
	
@private
	MapCoordinates* northWestCoordinates;
	MapCoordinates* southEastCoordinates;
}

@property(readonly,copy) MapCoordinates* northWestCoordinates;
@property(readonly,copy) MapCoordinates* southEastCoordinates;

- (id)initWithCoordinatesNorthWest:(MapCoordinates*) initNorthWestCoordinates
						 SouthEast:(MapCoordinates*) initSouthEastCoordinates;

- (double) northLatitude;
- (double) westLongitude;
- (double) southLatitude;
- (double) eastLongitude;

@end
