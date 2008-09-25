//
//  RMCachedTileSource.h
//  MapView
//
//  Created by Joseph Gentle on 25/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMTileSource.h"

// Simple wrapper around a tilesource which checks the image cache first.
@interface RMCachedTileSource : NSObject<RMTileSource> {
	id <RMTileSource> tileSource;
}

- (id) initWithSource: (id<RMTileSource>) source;

// Bleah ugly name.
+ (RMCachedTileSource*) cachedTileSourceWithSource: (id<RMTileSource>) source;

@end
