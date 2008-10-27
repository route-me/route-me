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

extern NSString * const RMMarkerBlueKey;
extern NSString * const RMMarkerRedKey;

@interface RMMarker : RMMapLayer <RMMovingMapLayer> {
	RMMercatorPoint location;
}

- (id) initWithKey: (NSString*) key;
- (id) initWithCGImage: (CGImageRef) image;
- (id) initWithUIImage: (UIImage*) image;

@property (assign, nonatomic) RMMercatorPoint location;

// Call this with either RMMarkerBlue or RMMarkerRed for the key.
+ (CGImageRef) markerImage: (NSString *) key;

@end
