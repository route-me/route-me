//
//  ImagesAppDelegate.m
//  Images
//
//  Created by Joseph Gentle on 13/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "ImagesAppDelegate.h"
#import "RootViewController.h"

@implementation ImagesAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
}


- (void)dealloc {
	[rootViewController release];
	[window release];
	[super dealloc];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	NSLog(@"applicationDidReceiveMemoryWarning");
}
@end
