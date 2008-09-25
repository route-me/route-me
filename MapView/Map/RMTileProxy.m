//
//  TileProxy.m
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileProxy.h"
#import "RMTileImage.h"

@implementation RMTileProxy

+(RMTileImage*) bestProxyFor: (RMTile) t
{
	return nil;
}

//static TileImage *_errorTile = nil;
static RMTileImage *_loadingTile = nil;

+(RMTileImage*) errorTile
{
	return nil;
}
+(RMTileImage*) loadingTile
{
	if (_loadingTile != nil)
		return _loadingTile;
	
	RMTile t = RMTileDummy();
	NSString* file = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	_loadingTile = [[RMTileImage imageWithTile:t FromFile:file] retain];
	return _loadingTile;
//	return nil;
}

@end
