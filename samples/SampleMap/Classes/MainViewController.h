//
//  MainViewController.h
//  SampleMap : Diagnostic map
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
@property(nonatomic,retain)RMMapContents *contents;

- (void)updateInfo;

@end
