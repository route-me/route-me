//
//  MapRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import "RMFoundation.h"

@class CALayer;
@class UIView;

@protocol RMTileSource;
@class RMMapContents;

@interface RMMapRenderer : NSObject
{
	RMMapContents *content;
}

- (id)initWithContent:(RMMapContents *)contents;
- (void)setNeedsDisplay;
- (void)drawRect:(CGRect)rect;
- (void)setFrame:(CGRect)frame;

- (CALayer*)layer;

@end
