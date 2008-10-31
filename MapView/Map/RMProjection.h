//
//  RMProjection.h
//  MapView
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "proj_api.h"

#import "RMFoundation.h"


@interface RMProjection : NSObject {
	projPJ		internalProjection;
}

@property (readonly) projPJ internalProjection;

+ (RMProjection *) googleProjection;
+ (RMProjection *) EPSGLatLong;
+ (RMProjection *) OSGB;


- (id) initWithString: (NSString*)params;

- (RMLatLong)pointToLatLong:(RMXYPoint)aPoint;
- (RMXYPoint)latLongToPoint:(RMLatLong)aLatLong;

@end
