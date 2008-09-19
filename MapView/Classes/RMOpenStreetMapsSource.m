//
//  OpenStreetMapsSource.m
//  Images
//
//  Created by Joseph Gentle on 19/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMOpenStreetMapsSource.h"

@implementation RMOpenStreetMapsSource

-(NSString*) tileURL: (RMTile) tile
{
	return [NSString stringWithFormat:@"http://tile.openstreetmap.org/%d/%d/%d.png", tile.zoom, tile.x, tile.y];
}

@end
