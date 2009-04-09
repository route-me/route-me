//
//  TileIssueViewController.h
//  TileIssue
//
//  Created by olivier on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMMapView.h"

@interface TileIssueViewController : UIViewController {
	 RMMapView *mapView;
}

@property (nonatomic, retain) RMMapView *mapView;

@end
