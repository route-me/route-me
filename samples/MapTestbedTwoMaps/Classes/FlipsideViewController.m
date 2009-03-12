//
//  FlipsideViewController.m
//  MapTestbed : Diagnostic map
//

#import "FlipsideViewController.h"
#import "MapTestbedTwoMapsAppDelegate.h"


@implementation FlipsideViewController

@synthesize centerLatitude;
@synthesize centerLongitude;
@synthesize zoomLevel;
@synthesize minZoom;
@synthesize maxZoom;

- (void)viewDidLoad {
    [super viewDidLoad];
    contents = [(MapTestbedTwoMapsAppDelegate *)[[UIApplication sharedApplication] delegate] upperMapContents];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];      
    
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
    CLLocationCoordinate2D mapCenter = [contents mapCenter];

    [centerLatitude setText:[NSString stringWithFormat:@"%f", mapCenter.latitude]];
    [centerLongitude setText:[NSString stringWithFormat:@"%f", mapCenter.longitude]];
    [zoomLevel setText:[NSString stringWithFormat:@"%f", contents.zoom]];
    [maxZoom setText:[NSString stringWithFormat:@"%f", contents.maxZoom]];
    [minZoom setText:[NSString stringWithFormat:@"%f", contents.minZoom]];

}

- (void)viewWillDisappear:(BOOL)animated {
    CLLocationCoordinate2D newMapCenter;
    
    newMapCenter.latitude = [[centerLatitude text] doubleValue];
    newMapCenter.longitude = [[centerLongitude text] doubleValue];
    [contents moveToLatLong:newMapCenter];
    [contents setZoom:[[zoomLevel text] floatValue]];
    [contents setMaxZoom:[[maxZoom text] floatValue]];
    [contents setMinZoom:[[minZoom text] floatValue]];
}

- (void)dealloc {
    self.centerLatitude = nil;
    self.centerLongitude = nil;
    self.zoomLevel = nil;
    self.minZoom = nil;
    self.maxZoom = nil;    
    [super dealloc];
}


@end
