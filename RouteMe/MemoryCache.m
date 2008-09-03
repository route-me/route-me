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

-(id)initWithParentSource: (id)source Capacity: (int) _capacity
{
	if (![super initWithParentSource: source])
		return nil;
	
	cache = [[NSMutableDictionary alloc] initWithCapacity:_capacity];
	
	return self;
}

-(id)initWithCapacity: (NSUInteger) _capacity
{
	return [self initWithParentSource:nil Capacity:20];
}

-(id)initWithParentSource: (id)source
{
	return [self initWithParentSource: source Capacity: 20];
}


-(void) dealloc
{
	[cache release];
	[super dealloc];
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

-(TileImage *) tileImage: (Tile) tile
{
	TileImage *image = [self cachedImage: tile];
	if (image != nil)
		return image;
	else
	{
		TileImage *image = [tileSource tileImage:tile];
		[self addTile:tile WithImage:image];
		return image;
	}
}

@end
