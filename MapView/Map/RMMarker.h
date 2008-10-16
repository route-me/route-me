//
//  RMMarker.h
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"
#import "RMMercator.h"

@class UIImage;

@interface RMMarker : RMMapLayer {
	RMMercatorPoint point;
}

- (id) initWithCGImage: (CGImageRef) image;
- (id) initWithUIImage: (UIImage*) image;

@end
