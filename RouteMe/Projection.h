//
//  Projection.h
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "proj_api.h"

@interface Projection : NSObject {
	projPJ internalProjection;
}

-(id) initWithString: (NSString*)params;
-(id) init;

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point;
-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point;

@property (readonly) projPJ internalProjection;


+(Projection*) EPSGGoogle;
+(Projection*) EPSGLatLong;

@end


/*
	bool is_initialized() const;
	bool is_geographic() const;
*/