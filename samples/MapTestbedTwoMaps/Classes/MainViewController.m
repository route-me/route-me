//
//  MainViewController.m
//  MapTestbed : Diagnostic map
//

#import "MainViewController.h"
#import "MapTestbedTwoMapsAppDelegate.h"
#import "RMCloudMadeMapSource.h"

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
    [super viewDidLoad];
	
    [upperMapView setDelegate:self];
    [(MapTestbedTwoMapsAppDelegate *)[[UIApplication sharedApplication] delegate] setUpperMapContents:[upperMapView contents]];
    upperMapContents = [upperMapView contents];

    [lowerMapView setDelegate:self];
    [(MapTestbedTwoMapsAppDelegate *)[[UIApplication sharedApplication] delegate] setLowerMapContents:[lowerMapView contents]];
    lowerMapContents = [lowerMapView contents];
	[lowerMapContents setTileSource:[[[RMCloudMadeMapSource alloc] init] autorelease]];
	[lowerMapView setNeedsDisplay];
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
