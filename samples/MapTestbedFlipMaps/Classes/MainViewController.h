//
//  MainViewController.h
//  MapTestbed : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"
#import "RMOpenCycleMapSource.h"
#import "RMOpenStreetMapSource.h"

@interface MainViewController : UIViewController <RMMapViewDelegate> {
	IBOutlet RMMapView * mapView;
	IBOutlet UITextView * infoTextView;
	IBOutlet UISegmentedControl *mapSelectControl;
}
@property (nonatomic, retain) IBOutlet RMMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * infoTextView;

- (IBAction) mapSelectChange;

- (void)updateInfo;

@end
