//
//  RMCachedTileSource.m
//  MapView
//
//  Created by Joseph Gentle on 25/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMCachedTileSource.h"
#import "RMTileCache.h"

@implementation RMCachedTileSource

- (id) initWithSource: (id<RMTileSource>) _source
{
	if ([_source isKindOfClass:[RMCachedTileSource class]])
	{
		[self dealloc];
		return _source;
	}
	
	if (![super init])
		return nil;
	
	tileSource = [_source retain];
	
	cache = [[RMTileCache alloc] initWithTileSource:tileSource];
	
	return self;
}

- (void) dealloc
{
	[tileSource release];
	[cache release];
	[super dealloc];
}

+ (RMCachedTileSource*) cachedTileSourceWithSource: (id<RMTileSource>) source
{
	// Doing this fixes a strange build warning...
	id theSource = source;
	return [[[RMCachedTileSource alloc] initWithSource:theSource] autorelease];
}

-(RMTileImage *) tileImage: (RMTile) tile
{
	RMTileImage *cachedImage = [cache cachedImage:tile];
	if (cachedImage != nil)
	{
		return cachedImage;
	}
	else
	{
		RMTileImage *image = [tileSource tileImage:tile];
		[cache addTile:tile WithImage:image];
		return image;
	}
}

-(id<RMMercatorToTileProjection>) mercatorToTileProjection
{
	return [tileSource mercatorToTileProjection];
}

-(RMProjection*) projection
{
	return [tileSource projection];
}

- (id<RMTileSource>) underlyingTileSource
{
	// I'm assuming that our tilesource isn't itself a cachedtilesource.
	// This class's initialiser should make sure of that.
	return tileSource;
}

-(float) minZoom
{
	return [tileSource minZoom];
}
-(float) maxZoom
{
	return [tileSource maxZoom];
}

@end
