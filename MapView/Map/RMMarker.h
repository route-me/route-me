//
//  RMMarker.h
//  MapView
//
//  Created by Joseph Gentle on 13/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapLayer.h"
#import "RMFoundation.h"

@class RMMarkerStyle;

extern NSString * const RMMarkerBlueKey;
extern NSString * const RMMarkerRedKey;

@interface RMMarker : RMMapLayer <RMMovingMapLayer> {
	RMXYPoint location;	
	NSObject* data;
}

+ (RMMarker*) markerWithNamedStyle: (NSString*) styleName;

- (id) initWithCGImage: (CGImageRef) image anchorPoint: (CGPoint) anchorPoint;
- (id) initWithCGImage: (CGImageRef) image;
- (id) initWithKey: (NSString*) key;
- (id) initWithUIImage: (UIImage*) image;
- (id) initWithStyle: (RMMarkerStyle*) style;
- (id) initWithNamedStyle: (NSString*) styleName;
- (void) dealloc;

@property (assign, nonatomic) RMXYPoint location;
@property (retain) NSObject* data;

// Call this with either RMMarkerBlue or RMMarkerRed for the key.
+ (CGImageRef) markerImage: (NSString *) key;

@end
