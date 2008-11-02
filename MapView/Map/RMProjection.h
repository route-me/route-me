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
	
	RMXYRect	bounds;
	
	BOOL		projectionWrapsHorizontally;
}

@property (readonly) projPJ internalProjection;
@property (readonly) RMXYRect bounds;
@property (readwrite) BOOL projectionWrapsHorizontally;

// Assuming the earth is round, this will wrap a point around the bounds. 
- (RMXYPoint) wrapPointHorizontally: (RMXYPoint) aPoint;

// This method wraps the x and clamps the y.
- (RMXYPoint) constrainPointToBounds: (RMXYPoint) aPoint;

+ (RMProjection *) googleProjection;
+ (RMProjection *) EPSGLatLong;
+ (RMProjection *) OSGB;

- (id) initWithString: (NSString*)params InBounds: (RMXYRect) projBounds;

- (RMLatLong)pointToLatLong:(RMXYPoint)aPoint;
- (RMXYPoint)latLongToPoint:(RMLatLong)aLatLong;

@end
