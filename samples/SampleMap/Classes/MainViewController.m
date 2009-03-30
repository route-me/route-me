//
//  MainViewController.m
//  SampleMap : Diagnostic map
//

#import "MainViewController.h"
#import "SampleMapAppDelegate.h"

#import "MainView.h"

#import "RMCloudMadeMapSource.h"

@implementation MainViewController

@synthesize mapView;
@synthesize infoTextView;
@synthesize contents;

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
	id myTilesource = [[[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d6934" styleNumber:999] autorelease];
    
	RMMapContents *myContents = [[[RMMapContents alloc] initWithView:mapView 
														  tilesource:myTilesource] autorelease];
	self.contents = myContents;
	self.mapView.contents = myContents;
	[(SampleMapAppDelegate *)[[UIApplication sharedApplication] delegate] setMapContents:myContents];
    [self updateInfo];
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
	self.contents = nil;
    [super dealloc];
}

- (void)updateInfo {
    CLLocationCoordinate2D mapCenter = [contents mapCenter];
    
    float routemeMetersPerPixel = [contents scale]; // really meters/pixel
    float iphoneMillimetersPerPixel = .1543;
	float truescaleDenominator =  routemeMetersPerPixel / (0.001 * iphoneMillimetersPerPixel) ;
    
    [infoTextView setText:[NSString stringWithFormat:@"Latitude : %f\nLongitude : %f\nZoom level : %.2f\nMeter per pixel : %.1f\nTrue scale : 1:%.0f\n%@\n%@", 
                           mapCenter.latitude, 
                           mapCenter.longitude, 
                           contents.zoom, 
                           routemeMetersPerPixel,
                           truescaleDenominator,
						   [[contents tileSource] shortName],
						   [[contents tileSource] shortAttribution]
						   ]];
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
