//
//  RMCachedTileSource.m
//
// Copyright (c) 2008, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

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

- (void) didReceiveMemoryWarning
{
	[cache didReceiveMemoryWarning];
}

-(NSString*) uniqueTilecacheKey
{
	return [tileSource uniqueTilecacheKey];
}

-(NSString *)shortName
{
	return [tileSource shortName];
}
-(NSString *)longDescription
{
	return [tileSource longDescription];
}
-(NSString *)shortAttribution
{
	return [tileSource shortAttribution];
}
-(NSString *)longAttribution
{
	return [tileSource longAttribution];
}

-(NSString *) tileURL: (RMTile) tile
{
  return [tileSource tileURL:tile];
}

-(NSString *) tileFile: (RMTile) tile
{
  return [tileSource tileFile:tile];
}

-(NSString *) tilePath
{
  return [tileSource tilePath];
}

@end
