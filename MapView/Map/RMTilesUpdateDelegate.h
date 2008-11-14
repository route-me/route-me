//
//  RMTilesUpdateDelegate.h
//
//  Created by Olivier Brand.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RMTilesUpdateDelegate 

@required

- (void) regionUpdate: (double) northWestLatitude NWLon:(double) northWestLongitude SELat:(double) southEastLatitude  SELon:(double) southEastLongitude;

@end
