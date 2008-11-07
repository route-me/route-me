//
//  RMCloudMadeMapSource.m
//  MapView
//
//  Created by Dmytro Golub on 10/29/08.
//  Copyright 2008 Cloudmade. Refer to project license.
//

#import "RMCloudMadeMapSource.h"


@implementation RMCloudMadeMapSource

-(NSString*) tileURL: (RMTile) tile
{
	return [NSString stringWithFormat:@"http://a.tile.cloudmade.com/0199bdee456e59ce950b0156029d6934/2/%d/%d/%d/%d.png",[RMCloudMadeMapSource tileSideLength], tile.zoom, tile.x, tile.y];
}

-(NSString*) description
{
	return @"CloudMadeMaps";
}

+(int)tileSideLength
{
	return 256;
}

@end
