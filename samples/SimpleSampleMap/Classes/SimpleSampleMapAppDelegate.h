//
//  SimpleSampleMapAppDelegate.h
//  SimpleSampleMap
//
//  Created by John Ahrens on 3/14/09.
//  Copyright John Ahrens, LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleSampleMapViewController;

@interface SimpleSampleMapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SimpleSampleMapViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SimpleSampleMapViewController *viewController;

@end

