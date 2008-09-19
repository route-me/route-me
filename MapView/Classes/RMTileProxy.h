//
//  TileProxy.h
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMTile.h"
@class RMTileImage;
@interface RMTileProxy : NSObject {
	
}

+(RMTileImage*) bestProxyFor: (RMTile) t;
+(RMTileImage*) errorTile;
+(RMTileImage*) loadingTile;

@end
