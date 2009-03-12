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

- (void)performTest
{
	NSLog(@"testing paths");
	CLLocationCoordinate2D northeast, southwest;
	northeast.latitude = 50;
	northeast.longitude = -80;
	southwest.latitude = 30;
	southwest.longitude = -130;
	[mapContents zoomWithLatLngBoundsNorthEast:northeast SouthWest:southwest];
	
	CLLocationCoordinate2D center, two, three;
	center.latitude = (southwest.latitude + northeast.latitude) / 2.0;
	center.longitude = (southwest.longitude + northeast.longitude) / 2.0;
	two.latitude = center.latitude + 15.;
	two.longitude = center.longitude - 15.;
	three.latitude = center.latitude;
	three.longitude = center.longitude - 20.;
	
	RMPath *testPath;
	testPath = [[RMPath alloc] initWithContents:mapContents];
	[testPath setLineColor:[UIColor greenColor]];
	[testPath setFillColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.2]];
	[testPath addLineToLatLong:center];
	[testPath addLineToLatLong:two];
	[testPath addLineToLatLong:three];
	[testPath closePath];
	[[mapContents overlay] addSublayer:testPath];
	[testPath release];

}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(performTest) withObject:nil afterDelay:1.0]; 
}


- (void)dealloc {
    self.mapContents = nil;
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
