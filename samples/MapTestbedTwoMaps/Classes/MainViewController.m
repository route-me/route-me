//
//  MainViewController.m
//  MapTestbed : Diagnostic map
//

#import "MainViewController.h"
#import "MapTestbedTwoMapsAppDelegate.h"
#import "RMMapContents.h"
#import "RMCloudMadeMapSource.h"
#import "RMVirtualEarthSource.h"

#import "MainView.h"

@implementation MainViewController

@synthesize upperMapView;
@synthesize lowerMapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	LogMethod();
    [super viewDidLoad];
	
	CLLocationCoordinate2D center;
	center.latitude = 47.592;
	center.longitude = -122.333;
	
    [upperMapView setDelegate:self];
    upperMapContents = [[RMMapContents alloc] initWithView:upperMapView
												tilesource:[[[RMVirtualEarthSource alloc] initWithHybridThemeUsingAccessKey:@"invalidKey"] autorelease]];
    [(MapTestbedTwoMapsAppDelegate *)[[UIApplication sharedApplication] delegate] setUpperMapContents:[upperMapView contents]];
	[upperMapView setNeedsLayout];
	[upperMapView setNeedsDisplay];
	[upperMapView moveToLatLong:center];
	
    [lowerMapView setDelegate:self];
    lowerMapContents =  [[RMMapContents alloc] initWithView:lowerMapView
												 tilesource:[[[RMCloudMadeMapSource alloc] initWithAccessKey:@"0199bdee456e59ce950b0156029d6934" styleNumber:7] autorelease]];
    [(MapTestbedTwoMapsAppDelegate *)[[UIApplication sharedApplication] delegate] setLowerMapContents:[lowerMapView contents]];
	[lowerMapView setNeedsDisplay];
	[lowerMapView moveToLatLong:center];
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
}

- (void)dealloc {
    self.upperMapView = nil; 
    self.lowerMapView = nil; 
    [super dealloc];
}

#pragma mark -
#pragma mark Delegate methods

- (void) afterMapMove: (RMMapView*) map {
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center {
}


@end
