//
//  TileIssueViewController.m
//  TileIssue
//
//  Created by olivier on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TileIssueViewController.h"


@implementation TileIssueViewController

@synthesize mapView;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	CLLocationCoordinate2D latlong;
	
	latlong.latitude = 75.715633;
	latlong.longitude =-128.935547;
	
	RMMapView *map = [[RMMapView alloc]initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen]applicationFrame].size.width, [[UIScreen mainScreen]applicationFrame].size.height-79) WithLocation:latlong];
	[self setMapView:map];
	[map release];
	[[[self mapView] contents]setZoom:16];
	
	self.view = mapView;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [NSThread detachNewThreadSelector: @selector(geocodeThread:) toTarget:self withObject:nil];
}

- (void)geocodeThread:(id)someLocation
{

		NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
	
		CLLocationCoordinate2D latlong;
	
		latlong.latitude = -29.210278;
		latlong.longitude =-59.680000;
		NSValue *vlocation= [NSValue value:&latlong withObjCType:@encode(CLLocationCoordinate2D)];
		[self performSelectorOnMainThread:@selector(moveToLatLon:)  withObject:vlocation waitUntilDone:NO];

		[pool release];

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
