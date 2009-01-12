//
//  freemap_iphoneAppDelegate.h
//  freemap-iphone
//
//  Created by admin on 8/12/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapViewController.h"

@interface freemap_iphoneAppDelegate : NSObject <UIApplicationDelegate> {
	
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;

	MapViewController *mapViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) MapViewController *mapViewController;

@end
