//
//  Sample2AppDelegate.m
//  Sample2 : Diagnostic map
//

#import "Sample2AppDelegate.h"
#import "RootViewController.h"

@implementation Sample2AppDelegate


@synthesize window;
@synthesize rootViewController;
@synthesize mapContents;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
