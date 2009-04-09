//
//  TileIssueAppDelegate.h
//  TileIssue
//
//  Created by olivier on 4/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TileIssueViewController.h";

@interface TileIssueAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	TileIssueViewController *tileIssueViewController;
	UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) TileIssueViewController *tileIssueViewController;
@property (nonatomic, retain) UINavigationController *navController;

@end

