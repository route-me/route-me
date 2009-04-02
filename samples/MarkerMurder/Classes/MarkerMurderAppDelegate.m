//
//  Sample2AppDelegate.m
//  SampleMap : Diagnostic map
//

#import "MarkerMurderAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"

@implementation MarkerMurderAppDelegate


@synthesize window;
@synthesize rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}

-(RMMapContents *)mapContents
{
	return self.rootViewController.mainViewController.mapView.contents;
}

- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
