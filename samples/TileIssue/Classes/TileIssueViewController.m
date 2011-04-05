//
//  TileIssueViewController.m
//  TileIssue
//
//  Created by olivier on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <unistd.h>
#import "TileIssueViewController.h"


@implementation TileIssueViewController

@synthesize mapView;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	CLLocationCoordinate2D latlong;
	
	latlong.latitude = 43.61675;
	latlong.longitude = 6.97167;
	
	RMMapView *map = [[RMMapView alloc]initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen]applicationFrame].size.width, [[UIScreen mainScreen]applicationFrame].size.height-79) WithLocation:latlong];
	[self setMapView:map];
	[map release];
	[[[self mapView] contents]setZoom:18];
	
	self.view = mapView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [NSThread detachNewThreadSelector: @selector(moveThread:) toTarget:self withObject:nil];
}

- (void)moveThread:(id)someLocation
{
	NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
	CLLocationCoordinate2D latlong;
	latlong.latitude = 43.61675;
	latlong.longitude = 6.97167;
	double s=1;
	for(int i=0; i<2; i++){
		sleep(3);
		latlong.longitude+=s*0.002;
		NSValue *vlocation= [NSValue value:&latlong withObjCType:@encode(CLLocationCoordinate2D)];
		[self performSelectorOnMainThread:@selector(moveToLatLon:) withObject:vlocation waitUntilDone:NO];
		s=-s;
	}
	[pool drain];

}

-(void)moveToLatLon:(NSValue *)vlocation
{
	CLLocationCoordinate2D location;  
	[vlocation getValue:&location]; 
	[mapView moveToLatLong:location];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[mapView release];
    [super dealloc];
}


@end
