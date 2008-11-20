//
//  MapViewViewController.h
//  MapView
//
//  Created by Joseph Gentle on 17/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@interface MapViewViewController : UIViewController <RMMapViewDelegate> {
	IBOutlet RMMapView * mapView;
	BOOL tap;
}

@end

