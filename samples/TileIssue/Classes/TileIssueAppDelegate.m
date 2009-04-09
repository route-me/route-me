//
//  TileIssueAppDelegate.m
//  TileIssue
//
//  Created by olivier on 4/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TileIssueAppDelegate.h"

@implementation TileIssueAppDelegate

@synthesize window;
@synthesize tileIssueViewController;
@synthesize navController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
	
	[self setTileIssueViewController:[[TileIssueViewController alloc]init]];
	
	UINavigationController *aNavigationViewCtrl = [[UINavigationController alloc]initWithRootViewController:[self tileIssueViewController]];
	[self setNavController:aNavigationViewCtrl];
	[aNavigationViewCtrl release];
	
	[window setBackgroundColor:[UIColor blueColor]];

	
	[window addSubview:[navController view]];
	[window makeKeyAndVisible];

}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
