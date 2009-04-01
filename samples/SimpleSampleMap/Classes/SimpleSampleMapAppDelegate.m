//
//  SimpleSampleMapAppDelegate.m
//  SimpleSampleMap
//
//  Created by John Ahrens on 3/14/09.
//  Copyright John Ahrens, LLC 2009. All rights reserved.
//

#import "SimpleSampleMapAppDelegate.h"
#import "SimpleSampleMapViewController.h"

@implementation SimpleSampleMapAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
