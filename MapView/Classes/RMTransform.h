//
//  Transform.h
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMLatLong.h"

@class RMProjection;
@interface RMTransform : NSObject {
	RMProjection* source;
	RMProjection* destination;
	
	bool is_source_latlong;
	bool is_dest_latlong;
}

-(id) initFrom: (RMProjection*)source To: (RMProjection*)dest;

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point AtZoom: (double)z;
-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point AtZoom: (double)z;

@end


/*
 proj_transform(projection const& source, 
 projection const& dest);
 
 bool forward (double& x, double& y , double& z) const;
 bool backward (double& x, double& y , double& z) const;
 
*/