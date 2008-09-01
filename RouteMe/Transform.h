//
//  Transform.h
//  Images
//
//  Created by Joseph Gentle on 18/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Projection;
@interface Transform : NSObject {
	Projection* source;
	Projection* destination;
	
	bool is_source_latlong;
	bool is_dest_latlong;
}

-(id) initFrom: (Projection*)source To: (Projection*)dest;

-(CLLocationCoordinate2D) projectForward: (CLLocationCoordinate2D)point AtZoom: (double)z;
-(CLLocationCoordinate2D) projectInverse: (CLLocationCoordinate2D)point AtZoom: (double)z;

@end


/*
 proj_transform(projection const& source, 
 projection const& dest);
 
 bool forward (double& x, double& y , double& z) const;
 bool backward (double& x, double& y , double& z) const;
 
*/