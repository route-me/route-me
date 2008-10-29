//
//  RMMarkerStyle.h
//  MapView
//
//  Created by Hauke Brandes on 29.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RMMarkerStyle : NSObject {
	
	UIImage* markerIcon;

	CGPoint anchorPoint;
	
}

@property (retain) UIImage* markerIcon;
@property (assign) CGPoint anchorPoint;

+ (RMMarkerStyle*) markerStyleWithIcon: (UIImage*) image;

- (RMMarkerStyle*) initWithIcon: (UIImage*) image;
- (void) dealloc;

@end
