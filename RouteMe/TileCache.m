//
//  TileCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 2/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TileCache.h"

@implementation TileCache

-(id)initWithParentSource: (id)source
{
	if (![super init])
		return nil;
	
	if ([[self class] isEqual:[TileCache class]])
	{
		[NSException raise:@"Abstract Class Exception" format:@"Error, attempting to instantiate TileCache directly."];
		[self release];
		return nil; 
	}
	
	tileSource = [source retain];
	
	return self;
}

-(void) dealloc
{
	[tileSource release];
	[super dealloc];
}

+(NSNumber*) tileHash: (Tile)tile
{
	return [NSNumber numberWithUnsignedLongLong: TileHash(tile)];
}

// Returns the cached image if it exists. nil otherwise.
-(TileImage*) cachedImage:(Tile)tile
{
	return nil;
}

// Add tile to cache
-(void)addTile: (Tile)tile WithImage: (TileImage*)image { }

-(FractalTileProjection*) tileProjection
{
	return [tileSource tileProjection];
}

@end
