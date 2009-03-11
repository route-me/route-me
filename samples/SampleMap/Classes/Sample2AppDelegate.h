//
//  Sample2AppDelegate.h
//  Sample2 : Diagnostic map
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"

@class RootViewController;

@interface Sample2AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
    RMMapContents *mapContents;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property(nonatomic,retain) RMMapContents *mapContents;

@end

