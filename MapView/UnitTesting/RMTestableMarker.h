//
//  RMTestableMarker.h
//  MapView
//
//  Created by Hal Mueller on 4/8/09.
//  Copyright 2009 Route-Me Contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RMMarker;

/// Subclass of RMMarker with lat/lon coordinates added, to verify correct projection calculations
@interface RMTestableMarker : RMMarker {
	/// original location in lat/lon, to see if projection really works correctly
	CLLocationCoordinate2D coordinate;
}

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end
