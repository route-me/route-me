//
//  MapViewAppDelegate.h
//  MapView
//
//  Created by Joseph Gentle on 17/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewViewController;

@interface MapViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MapViewViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MapViewViewController *viewController;

@end

