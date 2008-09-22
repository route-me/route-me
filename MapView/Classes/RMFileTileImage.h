//
//  FileTileImage.h
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMTileImage.h"

@interface RMFileTileImage : RMTileImage {

}

-(id)initWithTile: (RMTile) _tile FromFile: (NSString*) filename;

@end
