//
//  MainViewController.m
//  SampleMap : Diagnostic map
//

#import "MainViewController.h"
#import "MarkerMurderAppDelegate.h"

#import "MainView.h"

#import "RMOpenAerialMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMMapContents.h"
#import "RMMapView.h"
#import "RMMarkerManager.h"
#import "RMMarker.h"
#import "RMTestableMarker.h"
#import "RMMercatorToScreenProjection.h"
#import "RMProjection.h"

@implementation MainViewController

@synthesize mapView;
@synthesize infoTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void)addMarkers
{
	CLLocationCoordinate2D markerPosition;
#define kNumberRows 1
#define kNumberColumns 9
#define kSpacing 2.0

	UIImage *redMarkerImage = [UIImage imageNamed:@"marker-red.png"];
	UIImage *blueMarkerImage = [UIImage imageNamed:@"marker-blue.png"];
	markerPosition.latitude = center.latitude - ((kNumberRows - 1)/2.0 * kSpacing);
	int i, j;
	for (i = 0; i < kNumberRows; i++) {
		markerPosition.longitude = center.longitude - ((kNumberColumns - 1)/2.0 * kSpacing);
		for (j = 0; j < kNumberColumns; j++) {
			markerPosition.longitude += kSpacing;
			NSLog(@"%f %f", markerPosition.latitude, markerPosition.longitude);
			RMTestableMarker *newMarker;
			if ((markerPosition.longitude < -180) ||
				(markerPosition.longitude > 0))
				newMarker = [[RMTestableMarker alloc] initWithUIImage:redMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
			else
				newMarker = [[RMTestableMarker alloc] initWithUIImage:blueMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
#ifdef DEBUG
			[newMarker setCoordinate:markerPosition];
			[newMarker changeLabelUsingText:[NSString stringWithFormat:@"%4.1f", markerPosition.longitude]];
#endif
			[self.mapView.contents.markerManager addMarker:newMarker
			 AtLatLong:markerPosition];
		}
		markerPosition.latitude += kSpacing;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [mapView setDelegate:self];
	id myTilesource = [[[RMOpenStreetMapSource alloc] init] autorelease];
    
	// have to initialize the RMMapContents object explicitly if we want it to use a particular tilesource
	[[[RMMapContents alloc] initWithView:mapView 
							  tilesource:myTilesource] autorelease];

	center.latitude = 66.44;
	center.longitude = -179.0;

	[mapView moveToLatLong:center];
	[mapView.contents setZoom:6.0];
	[[mapView contents] moveBy:CGSizeMake(-5.0, 0.0)];
	[self updateInfo];
	[self performSelector:@selector(addMarkers) withObject:nil afterDelay:1.0];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
*/


- (void)didReceiveMemoryWarning {
	RMLog(@"didReceiveMemoryWarning %@", self);
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateInfo];
}

- (void)dealloc {
	LogMethod();
    self.infoTextView = nil; 
    self.mapView = nil; 
    [super dealloc];
}

- (void)updateInfo {
	RMMapContents *contents = self.mapView.contents;
    CLLocationCoordinate2D mapCenter = [contents mapCenter];
    
    [infoTextView setText:[NSString stringWithFormat:@"Latitude : %f\nLongitude : %f\nZoom level : %.2f\n%@", 
                           mapCenter.latitude, 
                           mapCenter.longitude, 
                           contents.zoom, 
						   [[contents tileSource] shortAttribution]
						   ]];
}

#ifdef DEBUG
- (void)testMarkerPositions
{
	LogMethod();
	RMMarkerManager *mangler = [[[self mapView] contents] markerManager];
								
	for (RMTestableMarker *theMarker in [mangler markers]) {
		CGPoint screenPosition = [mangler screenCoordinatesForMarker:theMarker];
		NSLog(@"%@ %3.1f %3.1f %f %f", theMarker, 
			  theMarker.coordinate.latitude, theMarker.coordinate.longitude,
			  screenPosition.y, screenPosition.x);
	}
}
#endif

#pragma mark -
#pragma mark Delegate methods

- (void) afterMapMove: (RMMapView*) map {
#ifdef DEBUG
	[self testMarkerPositions];
#endif
    [self updateInfo];
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
#ifdef DEBUG
	[self testMarkerPositions];
#endif
	[self updateInfo];
}


@end
