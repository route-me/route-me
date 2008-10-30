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
	
	return self;
}

- (void) dealloc
{
	[tileSource release];
	[super dealloc];
}

+ (RMCachedTileSource*) cachedTileSourceWithSource: (id<RMTileSource>) source
{
	return [[[RMCachedTileSource alloc] initWithSource:source] autorelease];
}

-(RMTileImage *) tileImage: (RMTile) tile
{
	RMTileImage *cachedImage = [[RMTileCache sharedCache] cachedImage:tile];
	if (cachedImage != nil)
	{
		return cachedImage;
	}
	else
	{
		return [tileSource tileImage:tile];
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

-(RMXYRect) bounds
{
	return [tileSource bounds];
}


@end
