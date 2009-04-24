//
//  RMMemoryCache.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
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

#import "RMMemoryCache.h"
#import "RMTileImage.h"

@implementation RMMemoryCache

-(id)initWithCapacity: (NSUInteger) _capacity
{
	if (![super init])
		return nil;

	RMLog(@"initializing memory cache %@ with capacity %d", self, _capacity);
	
	cache = [[NSMutableDictionary alloc] initWithCapacity:_capacity];
	
	if (_capacity < 1)
		_capacity = 1;
	capacity = _capacity;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageLoadingCancelled:)
												 name:RMMapImageLoadingCancelledNotification
											   object:nil];
	
	return self;
}

/// \bug magic number
-(id)init
{
	return [self initWithCapacity:32];
}

-(void) dealloc
{
	LogMethod();
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cache release];
	[super dealloc];
}

-(void) didReceiveMemoryWarning
{
	LogMethod();		
	[cache removeAllObjects];
}

-(void) removeTile: (RMTile) tile
{
//	RMLog(@"tile %d %d %d removed from cache", tile.x, tile.y, tile.zoom);
	[cache removeObjectForKey:[RMTileCache tileHash: tile]];
}

-(void) imageLoadingCancelled: (NSNotification*)notification
{
	[self removeTile: [[notification object] tile]];
}

-(RMTileImage*) cachedImage:(RMTile)tile
{
	NSNumber *key = [RMTileCache tileHash: tile];
	RMTileImage *image = [cache objectForKey:key];
	return image;
}

/// Remove the least-recently used image from cache, if cache is at or over capacity. Removes only 1 image.
-(void)makeSpaceInCache
{
	while ([cache count] >= capacity)
	{
		// Rather than scanning I would really like to be using a priority queue
		// backed by a heap here.
		
		NSEnumerator *enumerator = [cache objectEnumerator];
		RMTileImage *image;
		
		NSDate *oldestDate = nil;
		RMTileImage *oldestImage = nil;
		
		while ((image = (RMTileImage*)[enumerator nextObject]))
		{
			if (oldestDate == nil
				|| ([oldestDate timeIntervalSinceReferenceDate] > [[image lastUsedTime] timeIntervalSinceReferenceDate]))
			{
				oldestDate = [image lastUsedTime];
				oldestImage = image;
			}
		}
		
		[self removeTile:[oldestImage tile]];
	}
}

-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image
{
	if (RMTileIsDummy(tile))
		return;
	
	//	RMLog(@"cache add %@", key);

	[self makeSpaceInCache];
	
	NSNumber *key = [RMTileCache tileHash: tile];
	[cache setObject:image forKey:key];
}

-(void) removeAllCachedImages 
{
	[cache removeAllObjects];
}

@end
