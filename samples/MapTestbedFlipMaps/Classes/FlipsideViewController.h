//
//  FlipsideViewController.h
//  MapTestbed : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@interface FlipsideViewController : UIViewController  <RMMapViewDelegate> {
	IBOutlet RMMapView * mapView;
	IBOutlet UITextView * infoTextView;
    RMMapContents *contents;
}
@property (nonatomic, retain) IBOutlet RMMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * infoTextView;

- (void)updateInfo;

@end

