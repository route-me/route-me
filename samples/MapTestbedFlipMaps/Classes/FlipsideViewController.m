//
//  FlipsideViewController.m
//  MapTestbed : Diagnostic map
//

#import "FlipsideViewController.h"
#import "MapTestbedAppDelegate.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"


@implementation FlipsideViewController

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
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue.png"]
											 anchorPoint:CGPointMake(0.5, 1.0)];
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
    
    float routemeMetersPerPixel = [contents metersPerPixel]; 
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

- (void)mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event 
{
   CGPoint position = [[[event allTouches] anyObject] locationInView:mapView];
   
	RMMarkerManager *markerManager = [mapView markerManager];

	NSLog(@"New location: X:%lf Y:%lf", [marker projectedLocation].easting, [marker projectedLocation].northing);
	CGRect rect = [marker bounds];
	
	[markerManager moveMarker:marker AtXY:CGPointMake(position.x,position.y +rect.size.height/3)];

}

- (void) afterMapMove: (RMMapView*) map {
    [self updateInfo];
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
    [self updateInfo];
}


@end
