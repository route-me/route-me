//
//  MapRenderer.h
//  RouteMe
//
//  Created by Joseph Gentle on 8/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMercator.h"

@class CALayer;
@class UIView;

@protocol RMTileSource;
@class RMMapContents;

@interface RMMapRenderer : NSObject
{
	RMMapContents *content;
}

- (id) initForView: (UIView*) view WithContent: (RMMapContents *)contents;
- (void) setNeedsDisplay;
- (void)drawRect:(CGRect)rect;

@end
