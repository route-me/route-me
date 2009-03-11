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
	NSLog(@"testing large zoom region");
	CLLocationCoordinate2D northeast, southwest;
	northeast.latitude = 60;
	northeast.longitude = -50;
	southwest.latitude = -50;
	southwest.longitude = -250;
	
	[mapContents zoomWithLatLngBoundsNorthEast:northeast SouthWest:southwest];

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
