//
//  MemoryCache.m
//  Images
//
//  Created by Joseph Gentle on 30/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MemoryCache.h"
#import "TileImage.h"

@implementation MemoryCache

-(id)initWithCapacity: (NSUInteger) _capacity
{
	if (![super init])
		return nil;

	cache = [[NSMutableDictionary alloc] initWithCapacity:_capacity];
	
	if (_capacity < 1)
		_capacity = 1;
	capacity = _capacity;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageLoadingCancelled:)
												 name:MapImageLoadingCancelledNotification
											   object:nil];
	
	return self;
}

-(id)init
{
	return [self initWithCapacity:5];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cache release];
	[super dealloc];
}

-(void) removeTile: (Tile) tile
{
	NSLog(@"tile %d %d %d removed from cache", tile.x, tile.y, tile.zoom);
	[cache removeObjectForKey:[TileCache tileHash: tile]];
}

-(void) imageLoadingCancelled: (NSNotification*)notification
{
	[self removeTile: [[notification object] tile]];
}

-(TileImage*) cachedImage:(Tile)tile
{
	NSNumber *key = [TileCache tileHash: tile];
	TileImage *image = [cache objectForKey:key];
	
/*	if (image == nil)
		NSLog(@"cache miss %@", key);
	else
		NSLog(@"cache hit %@", key);
*/	
	return image;
}

-(void)makeSpaceInCache
{
	while ([cache count] >= capacity)
	{
		// Rather than scanning I would really like to be using a priority queue
		// backed by a heap here.
		
		NSEnumerator *enumerator = [cache objectEnumerator];
		TileImage *image;
		
		NSDate *oldestDate = nil;
		TileImage *oldestImage = nil;
		
		while ((image = (TileImage*)[enumerator nextObject]))
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

-(void)addTile: (Tile)tile WithImage: (TileImage*)image
{
	if (TileIsDummy(tile))
		return;
	
	//	NSLog(@"cache add %@", key);

	[self makeSpaceInCache];
	
	NSNumber *key = [TileCache tileHash: tile];
	[cache setObject:image forKey:key];
}

@end
