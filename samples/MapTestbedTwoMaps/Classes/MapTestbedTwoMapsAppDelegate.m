//
//  MapTestbedAppDelegate.m
//  MapTestbed : Diagnostic map
//

#import "MapTestbedTwoMapsAppDelegate.h"
#import "RootViewController.h"

#import "RMPath.h"

@implementation MapTestbedTwoMapsAppDelegate


@synthesize window;
@synthesize rootViewController;
@synthesize upperMapContents;
@synthesize lowerMapContents;

- (void)performTest
{

}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[self performSelector:@selector(performTest) withObject:nil afterDelay:1.0]; 
}


- (void)dealloc {
    self.upperMapContents = nil;
	self.lowerMapContents = nil;
	[rootViewController release];
    [window release];
    [super dealloc];
}

@end
