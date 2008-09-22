//
//  Projection.h
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMLatLong.h"
#import "proj_api.h"

@interface RMProjection : NSObject {
	projPJ internalProjection;
}

-(id) initWithString: (NSString*)params;
-(id) init;

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point;
-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point;

@property (readonly) projPJ internalProjection;


+(RMProjection*) EPSGGoogle;
+(RMProjection*) EPSGLatLong;

@end


/*
	bool is_initialized() const;
	bool is_geographic() const;
*/