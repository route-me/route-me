//
//  RMMarker.h
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"

@interface RMMarker : RMMapLayer {
	
}

- (id) initWithCGImage: (CGImageRef) image;
- (id) initWithUIImage: (UIImage*) image;

@end
