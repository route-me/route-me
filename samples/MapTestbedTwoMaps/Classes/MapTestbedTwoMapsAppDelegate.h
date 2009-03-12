//
//  MapTestbedAppDelegate.h
//  MapTestbed : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@class RootViewController;
@class RMMapContents;

@interface MapTestbedTwoMapsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
    RMMapContents *upperMapContents;
    RMMapContents *lowerMapContents;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property(nonatomic,retain) RMMapContents *upperMapContents;
@property(nonatomic,retain) RMMapContents *lowerMapContents;

@end

