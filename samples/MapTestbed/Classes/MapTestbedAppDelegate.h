//
//  MapTestbedAppDelegate.h
//  MapTestbed : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@class RootViewController;
@class RMMapContents;

@interface MapTestbedAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
    RMMapContents *mapContents;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property(nonatomic,retain) RMMapContents *mapContents;

@end

