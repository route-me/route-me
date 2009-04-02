//
//  FlipsideViewController.m
//  SampleMap : Diagnostic map
//

#import "FlipsideViewController.h"
#import "MarkerMurderAppDelegate.h"


@implementation FlipsideViewController

@synthesize centerLatitude;
@synthesize centerLongitude;
@synthesize zoomLevel;
@synthesize minZoom;
@synthesize maxZoom;

- (void)viewDidLoad {
    [super viewDidLoad];

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
	RMLog(@"didReceiveMemoryWarning %@", self);
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)viewDidAppear:(BOOL)animated {
	
    CLLocationCoordinate2D mapCenter = [self.contents mapCenter];

    [centerLatitude setText:[NSString stringWithFormat:@"%f", mapCenter.latitude]];
    [centerLongitude setText:[NSString stringWithFormat:@"%f", mapCenter.longitude]];
    [zoomLevel setText:[NSString stringWithFormat:@"%.1f", self.contents.zoom]];
    [maxZoom setText:[NSString stringWithFormat:@"%.1f", self.contents.maxZoom]];
    [minZoom setText:[NSString stringWithFormat:@"%.1f", self.contents.minZoom]];

}

- (void)viewWillDisappear:(BOOL)animated {
    CLLocationCoordinate2D newMapCenter;
    
    newMapCenter.latitude = [[centerLatitude text] doubleValue];
    newMapCenter.longitude = [[centerLongitude text] doubleValue];
    [self.contents moveToLatLong:newMapCenter];
    [self.contents setZoom:[[zoomLevel text] floatValue]];
    [self.contents setMaxZoom:[[maxZoom text] floatValue]];
    [self.contents setMinZoom:[[minZoom text] floatValue]];
}

- (void)dealloc {
    self.centerLatitude = nil;
    self.centerLongitude = nil;
    self.zoomLevel = nil;
    self.minZoom = nil;
    self.maxZoom = nil;    
    [super dealloc];
}

- (RMMapContents *)contents
{
	return [(MarkerMurderAppDelegate *)[[UIApplication sharedApplication] delegate] mapContents];
}

- (IBAction)clearSharedNSURLCache
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (IBAction)clearMapContentsCachedImages
{
	[self.contents removeAllCachedImages];
}


@end
