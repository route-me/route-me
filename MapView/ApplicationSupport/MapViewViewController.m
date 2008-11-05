//
//  MapViewViewController.m
//  MapView
//
//  Created by Joseph Gentle on 17/09/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "MapViewViewController.h"

#import "RMMapContents.h"
#import "RMFoundation.h"
#import "RMMarker.h"

@implementation MapViewViewController

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];

/*	RMMarker *marker = [[RMMarker alloc] initWithKey:RMMarkerBlueKey];
	
	RMMercatorRect loc = [[mapView contents] mercatorBounds];
	loc.origin.x += loc.size.width / 2;
	loc.origin.y += loc.size.height / 2;

	marker.location = loc.origin;
	[[[mapView contents] overlay] addSublayer:marker];
	NSLog(@"marker added to %f %f", loc.origin.x, loc.origin.y);*/
	
	[mapView addDefaultMarkerAt:[[mapView contents] mapCenter]];
	
	NSArray *markers = [mapView getMarkers];
	
	NSLog(@"Nb markers %d", [markers count]);
	
	NSEnumerator *markerEnumerator = [markers objectEnumerator];
	RMMarker *aMarker;
	
	while (aMarker = (RMMarker *)[markerEnumerator nextObject])
		
	{
		RMXYPoint point = [aMarker location];
		NSLog(@"Marker mercator location: X:%lf, Y:%lf", point.x, point.y);
		CGPoint screenPoint = [mapView getMarkerScreenCoordinate: aMarker];
		NSLog(@"Marker screen location: X:%lf, Y:%lf", screenPoint.x, screenPoint.y);

		[mapView removeMarker:aMarker];
	}
	
	// Put the marker back
	[mapView addDefaultMarkerAt:[[mapView contents] mapCenter]];
	
	

	
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

@end
