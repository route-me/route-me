//
//  ProgrammaticMapViewController.h
//  ProgrammaticMap
//
//  Created by Hal Mueller on 3/25/09.
//  Copyright Route-Me Contributors 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMMapView;
@interface ProgrammaticMapViewController : UIViewController {
	RMMapView *mapView;
}

@property(nonatomic,retain)RMMapView *mapView;

- (IBAction) doTheTest:(id)sender;

@end

