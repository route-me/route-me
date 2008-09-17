//
//  LayeredTileImageSet.h
//  RouteMe
//
//  Created by Joseph Gentle on 9/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileLoader.h"

#import "Mercator.h"

@interface LayeredTileLoader : TileLoader {
	CALayer *layer;
}

@property (readonly, nonatomic) CALayer *layer;

- (id) initForScreen: (ScreenProjection*)screen FromImageSource: (id<TileSource>)source;

@end
