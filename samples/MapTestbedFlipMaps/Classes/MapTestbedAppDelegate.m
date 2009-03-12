//
//  MapTestbedAppDelegate.m
//  MapTestbed : Diagnostic map
//

#import "MapTestbedAppDelegate.h"
#import "RootViewController.h"

#import "RMPath.h"

@implementation MapTestbedAppDelegate


@synthesize window;
@synthesize rootViewController;
@synthesize mapContents;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    self.mapContents = nil;
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
