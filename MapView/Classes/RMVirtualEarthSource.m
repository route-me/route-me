//
//  RMVirtualEarthURL.m
//  MapView
//
//  Created by Brian Knorr on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMVirtualEarthSource.h"


@implementation RMVirtualEarthSource

-(NSString*) tileURL: (RMTile) tile
{
	NSString *quadKey = [self quadKeyForTile:tile];
	return [self urlForQuadKey:quadKey];
}

-(NSString*) quadKeyForTile: (RMTile) tile
{
	NSMutableString *quadKey = [NSMutableString string];
	for (int i = tile.zoom; i > 0; i--)
	{
		int mask = 1 << (i - 1);
		int cell = 0;
		if ((tile.x & mask) != 0)
		{
			cell++;
		}
		if ((tile.y & mask) != 0)
		{
			cell += 2;
		}
		[quadKey appendString:[NSString stringWithFormat:@"%d", cell]];
	}
	return quadKey;
}

-(NSString*) urlForQuadKey: (NSString*) quadKey 
{
	NSString *mapType = @"r"; //type road
	NSString *mapExtension = @".png"; //extension
	
	//TODO what is the ?g= hanging off the end 1 or 15?
	return [NSString stringWithFormat:@"http://%@%d.ortho.tiles.virtualearth.net/tiles/%@%@%@?g=15", mapType, 3, mapType, quadKey, mapExtension];
}

@end
