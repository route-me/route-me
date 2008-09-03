//
//  FileTileImage.h
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TileImage.h"

@interface FileTileImage : TileImage {

}

-(id)initWithTile: (Tile) _tile FromFile: (NSString*) filename;

@end
