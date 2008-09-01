//
//  TileProxy.h
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tile.h"
@class TileImage;
@interface TileProxy : NSObject {
	
}

+(TileImage*) bestProxyFor: (Tile) t;
+(TileImage*) errorTile;
+(TileImage*) loadingTile;

@end
