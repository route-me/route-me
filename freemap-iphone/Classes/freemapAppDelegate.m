//
//  freemap_iphoneAppDelegate.m
//  freemap-iphone
//
//  Created by admin on 8/12/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "freemapAppDelegate.h"

#import "MapView.h"

@implementation freemap_iphoneAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize mapViewController;

- (id)init {
	if (self = [super init]) {
		//NSLog(@"freemapAppDelegate::init");
	}
	return self;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//NSLog(@"freemapAppDelegate::applicationDidFinishLaunching");
	
	mapViewController = [[MapViewController alloc] 
			 initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]];
	[navigationController pushViewController:mapViewController animated:TRUE];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
  //NSLog(@"freemapAppDelegate::applicationWillTerminate");
	
  // Save data if appropriate
  MapView* mapView = (MapView*) [mapViewController view];
  [mapView saveMapState];
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[mapViewController release];
	
	[super dealloc];
}

@end
