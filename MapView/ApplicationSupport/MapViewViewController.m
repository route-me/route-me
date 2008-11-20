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

#import "RMMarkerManager.h"

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

- (void)testMarkers
{
	RMMarkerManager *markerManager = [mapView markerManager];
	NSArray *markers = [markerManager getMarkers];
	
	NSLog(@"Nb markers %d", [markers count]);
	
	NSEnumerator *markerEnumerator = [markers objectEnumerator];
	RMMarker *aMarker;
	
	while (aMarker = (RMMarker *)[markerEnumerator nextObject])
		
	{
		RMXYPoint point = [aMarker location];
		NSLog(@"Marker mercator location: X:%lf, Y:%lf", point.x, point.y);
		CGPoint screenPoint = [markerManager getMarkerScreenCoordinate: aMarker];
		NSLog(@"Marker screen location: X:%lf, Y:%lf", screenPoint.x, screenPoint.y);
		CLLocationCoordinate2D coordinates =  [markerManager getMarkerCoordinate2D: aMarker];
		NSLog(@"Marker Lat/Lon location: Lat:%lf, Lon:%lf", coordinates.latitude, coordinates.longitude);
		
		[markerManager removeMarker:aMarker];
	}
	
	// Put the marker back
	RMMarker *marker = [[RMMarker alloc]initWithKey:RMMarkerBlueKey];
	[marker setTextLabel:@"Hello"];
	
	[markerManager addMarker:marker AtLatLong:[[mapView contents] mapCenter]];
//	[markerManager addDefaultMarkerAt:[[mapView contents] mapCenter]];
	[marker release];
	markers  = [markerManager getMarkersForScreenBounds];
	
	NSLog(@"Nb Markers in Screen: %d", [markers count]);
	
	//	[mapView getScreenCoordinateBounds];
	
	[markerManager hideAllMarkers];
	[markerManager unhideAllMarkers];
}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
	NSLog(@"MARKER TAPPED!");
	[marker removeLabel];
	if(!tap)
	{
		[marker replaceImage:[[UIImage imageNamed:@"marker-red.png"] CGImage]   anchorPoint:CGPointMake(0.5,1.0)];
	//	[marker setTextLabel:@"World"];
		tap=YES;
	}else
	{
		[marker replaceImage:[[UIImage imageNamed:@"marker-blue.png"] CGImage]   anchorPoint:CGPointMake(0.5,1.0)];
	//	[marker setTextLabel:@"Hello"];
		tap=NO;
	}

}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	tap=NO;
	RMMarkerManager *markerManager = [mapView markerManager];
	[mapView setDelegate:self];
	
	CLLocationCoordinate2D coolPlace;
	coolPlace.latitude = -33.9464;
	coolPlace.longitude = 151.2381;
	
//	[markerManager addDefaultMarkerAt:coolPlace];
	
	RMMarker *marker = [[RMMarker alloc]initWithKey:RMMarkerBlueKey];
	[marker setTextLabel:@"Hello"];
	[markerManager addMarker:marker AtLatLong:[[mapView contents] mapCenter]];
	[marker release];
	
	// What did this do?
	//	[mapView setZoomBounds:0.0 maxZoom:17.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// due to a bug, RMMapView should never be released, as it causes the application to crash
    //[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview

	[mapView.contents didReceiveMemoryWarning];
}


- (void)dealloc {
    [super dealloc];
}

@end
