//
//  MainViewController.m
//  MapTestbed : Diagnostic map
//

#import "MainViewController.h"
#import "MapTestbedAppDelegate.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"

#import "MainView.h"

@implementation MainViewController

@synthesize mapView;
@synthesize infoTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [mapView setDelegate:self];
    [self updateInfo];
    
    RMMarkerManager *markerManager = [mapView markerManager];
	NSAssert(markerManager, @"null markerManager returned");
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]];
	[marker setTextForegroundColor:[UIColor blueColor]];
	[marker changeLabelUsingText:@"Hello"];
	[markerManager addMarker:marker AtLatLong:[[mapView contents] mapCenter]];
	[marker release];

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

- (void)viewDidAppear:(BOOL)animated {
    [self updateInfo];
}

- (void)dealloc {
    self.infoTextView = nil; 
    self.mapView = nil; 
    [super dealloc];
}

- (void)updateInfo {
	RMMapContents *contents = self.mapView.contents;
    CLLocationCoordinate2D mapCenter = [contents mapCenter];
    
    float routemeMetersPerPixel = [contents metersPerPixel]; // really meters/pixel
	double truescaleDenominator =  [contents scaleDenominator];
    
    [infoTextView setText:[NSString stringWithFormat:@"Latitude : %f\nLongitude : %f\nZoom level : %.2f\nMeter per pixel : %.1f\nTrue scale : 1:%.0f", 
                           mapCenter.latitude, 
                           mapCenter.longitude, 
                           contents.zoom, 
                           routemeMetersPerPixel,
                           truescaleDenominator]];
}

#pragma mark -
#pragma mark Delegate methods

- (void) afterMapMove: (RMMapView*) map {
    [self updateInfo];
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    [self updateInfo];
}


@end
