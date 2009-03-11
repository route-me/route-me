//
//  MapTestbedAppDelegate.m
//  MapTestbed : Diagnostic map
//

#import "MapTestbedAppDelegate.h"
#import "RootViewController.h"

@implementation MapTestbedAppDelegate


@synthesize window;
@synthesize rootViewController;
@synthesize mapContents;

- (void)performTest
{
	NSLog(@"moving to Seattle");
	CLLocationCoordinate2D destination;
	destination.latitude = 47.62;
	destination.longitude = -122.35;

	[mapContents moveToLatLong:destination];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(performTest) withObject:nil afterDelay:3.0]; 
}


- (void)dealloc {
    self.mapContents = nil;
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
