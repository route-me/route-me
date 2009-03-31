//
//  ProgrammaticMapViewController.m
//  ProgrammaticMap
//
//  Created by Hal Mueller on 3/25/09.
//  Copyright Route-Me Contributors 2009. All rights reserved.
//

#import "ProgrammaticMapViewController.h"
#import "RMMapView.h"

@implementation ProgrammaticMapViewController

@synthesize mapView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (void)viewDidLoad {
	NSLog(@"viewDidLoad");
    [super viewDidLoad];
	
	CLLocationCoordinate2D firstLocation;
	firstLocation.latitude = 51.2795;
	firstLocation.longitude = 1.082;
	self.mapView = [[[RMMapView alloc] initWithFrame:CGRectMake(10,20,200,300)
										WithLocation:firstLocation] autorelease];
//	[[mapView contents] setZoom:10.0];
	[mapView setBackgroundColor:[UIColor greenColor]];
	[[self view] addSubview:mapView];
	[[self view] sendSubviewToBack:mapView];
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
	[mapView didReceiveMemoryWarning];
}


- (void)dealloc {
    [mapView removeFromSuperview];
	self.mapView = nil;
	[super dealloc];
}

- (IBAction) doTheTest:(id)sender
{
	CLLocationCoordinate2D secondLocation;
	secondLocation.latitude = -43.63;
	secondLocation.longitude = 172.66;
	[[[self mapView] contents] moveToLatLong:secondLocation];
}

@end
