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
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageLoadingCancelled:)
												 name:MapImageLoadingCancelledNotification
											   object:nil];
	
	return self;
}

-(id)init
{
	return [self initWithCapacity:20];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[cache release];
	[super dealloc];
}

-(void) removeTile: (Tile) tile
{
//	NSLog(@"tile removed from cache");
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

-(void)addTile: (Tile)tile WithImage: (TileImage*)image
{
	NSNumber *key = [TileCache tileHash: tile];

//	NSLog(@"cache add %@", key);

	[cache setObject:image forKey:key];
}

@end
