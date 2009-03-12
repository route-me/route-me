//
//  MainViewController.h
//  MapTestbed : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@interface MainViewController : UIViewController <RMMapViewDelegate> {
	IBOutlet RMMapView * upperMapView;
    RMMapContents *upperMapContents;
	IBOutlet RMMapView * lowerMapView;
    RMMapContents *lowerMapContents;
}
@property (nonatomic, retain) IBOutlet RMMapView * upperMapView;
@property (nonatomic, retain) IBOutlet RMMapView * lowerMapView;

@end
