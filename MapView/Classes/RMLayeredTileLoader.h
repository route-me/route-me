//
//  LayeredTileImageSet.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileLoader.h"

#import "RMMercator.h"

@class CALayer;

@interface RMLayeredTileLoader : RMTileLoader {
	CALayer *layer;
}

@property (readonly, nonatomic) CALayer *layer;

- (id) initForScreen: (RMScreenProjection*)screen FromImageSource: (id<RMTileSource>)source;

@end
