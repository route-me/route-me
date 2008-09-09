//
//  TileProxy.m
//  Images
//
//  Created by Joseph Gentle on 1/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileProxy.h"
#import "TileImage.h"

@implementation TileProxy

+(TileImage*) bestProxyFor: (Tile) t
{
	return nil;
}

static TileImage *_errorTile = nil;
static TileImage *_loadingTile = nil;

+(TileImage*) errorTile
{
	return nil;
}
+(TileImage*) loadingTile
{
	if (_loadingTile != nil)
		return _loadingTile;
	
	Tile t = TileDummy();
	NSString* file = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"];
	_loadingTile = [[TileImage imageWithTile:t FromFile:file] retain];
	return _loadingTile;
//	return nil;
}

@end
