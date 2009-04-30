//
//  MapTestbedAppDelegate.m
//  MapTestbed : Diagnostic map
//

#import "MapTestbedAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"

#import "RMPath.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"

@implementation MapTestbedAppDelegate


@synthesize window;
@synthesize rootViewController;

-(RMMapContents *)mapContents
{
	return self.rootViewController.mainViewController.mapView.contents;
}
-(void)performTestPart2
{
	// a bug exists that offsets the path when we execute this moveToLatLong
	CLLocationCoordinate2D pt;
	pt.latitude = 48.86600492029781f;
	pt.longitude = 2.3194026947021484f;
	
	[self.mapContents moveToLatLong: pt];
}


-(void)performTestPart3
{
	// path returns to correct position after this zoom
	CLLocationCoordinate2D northeast, southwest;
	northeast.latitude = 48.885875363989435f;
	northeast.longitude = 2.338285446166992f;
	southwest.latitude = 48.860406466081656f;
	southwest.longitude = 2.2885894775390625;
	
	[self.mapContents zoomWithLatLngBoundsNorthEast:northeast SouthWest:southwest];
}	


- (void)performTest
{
	NSLog(@"testing paths");
	RMMapContents *mapContents = [self mapContents];

	UIImage *xMarkerImage = [UIImage imageNamed:@"marker-X.png"];
	
	// if we zoom with bounds after the paths are created, nothing is displayed on the map
	CLLocationCoordinate2D northeast, southwest;
	northeast.latitude = 48.885875363989435f;
	northeast.longitude = 2.338285446166992f;
	southwest.latitude = 48.860406466081656f;
	southwest.longitude = 2.2885894775390625;
	[mapContents zoomWithLatLngBoundsNorthEast:northeast SouthWest:southwest];
	
	CLLocationCoordinate2D one, two, three, four;
	one.latitude = 48.884238608729035f;
	one.longitude = 2.297086715698242f;
	two.latitude = 48.878481319827735f;
	two.longitude = 2.294340133666992f;
	three.latitude = 48.87351371451778f;
	three.longitude = 2.2948551177978516f;
	four.latitude = 48.86600492029781f;
	four.longitude = 2.3194026947021484f;
	
	// draw a green path south down an avenue and southeast on Champs-Elysees
	RMPath *testPath, *testRegion;
	testPath = [[RMPath alloc] initWithContents:mapContents];
	[testPath setLineColor:[UIColor greenColor]];
	[testPath setFillColor:[UIColor clearColor]];
	[testPath setLineWidth:40.0f];
	[testPath setDrawingMode:kCGPathStroke];
	[testPath addLineToLatLong:one];
	[testPath addLineToLatLong:two];
	[testPath addLineToLatLong:three];
	[testPath addLineToLatLong:four];
	[[mapContents overlay] addSublayer:testPath];
	[testPath release];

	RMMarker *newMarker;
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:one];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:two];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:three];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:four];
	
	CLLocationCoordinate2D r1, r2, r3, r4;
	r1.latitude = 48.86637615203047f;
	r1.longitude = 2.3236513137817383f;
	r2.latitude = 48.86372241857954f;
	r2.longitude = 2.321462631225586f;
	r3.latitude = 48.86087090984738f;
	r3.longitude = 2.330174446105957f;
	r4.latitude = 48.86369418661614f;
	r4.longitude = 2.332019805908203f;
	
	// draw a blue-filled rectangle on top of the Tuileries
	testRegion = [[RMPath alloc] initWithContents:mapContents];
	[testRegion setFillColor:[UIColor colorWithRed: 0.1 green:0.1 blue: 0.8 alpha: 0.5 ]];
	[testRegion setLineColor:[UIColor blueColor]];
	[testRegion setLineWidth:20.0f];
	[testRegion setDrawingMode:kCGPathFillStroke];
	[testRegion addLineToLatLong:r1];
	[testRegion addLineToLatLong:r2];
	[testRegion addLineToLatLong:r3];
	[testRegion addLineToLatLong:r4];
	[testRegion closePath];
	[[mapContents overlay] addSublayer:testRegion];
	[testRegion release];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:r1];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:r2];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:r3];
	newMarker = [[RMMarker alloc] initWithUIImage:xMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
	[mapContents.markerManager addMarker:[newMarker autorelease] AtLatLong:r4];
	
	[self performSelector:@selector(performTestPart2) withObject:nil afterDelay:3.0f]; 
	[self performSelector:@selector(performTestPart3) withObject:nil afterDelay:7.0f]; 
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	
	[self performSelector:@selector(performTest) withObject:nil afterDelay:0.25f]; 

}


- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
