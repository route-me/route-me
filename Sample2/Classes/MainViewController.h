//
//  MainViewController.h
//  Sample2 : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@interface MainViewController : UIViewController <RMMapViewDelegate> {
	IBOutlet RMMapView * mapView;
	IBOutlet UITextView * infoTextView;
    RMMapContents *contents;
}
@property (nonatomic, retain) IBOutlet RMMapView * mapView;
@property (nonatomic, retain) IBOutlet UITextView * infoTextView;

- (void)updateInfo;

@end
