//
//  ImagesAppDelegate.h
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ImagesAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet RootViewController *rootViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *rootViewController;

@end

