//
//  RMDatabaseCache.m
//  RouteMe
//
//  Created by Joseph Gentle on 19/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMDatabaseCache.h"
#import "RMTileCacheDAO.h"
#import "RMTileImage.h"
#import "RMTile.h"

//static BOOL installed = NO;

@implementation RMDatabaseCache

-(id) init
{
	if (![super init])
		return nil;
	
//	NSLog(@"%d items in DB", [[DAO sharedManager] count]);
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(addImageData:)
												 name:RMMapImageLoadedNotification
											   object:nil];
	
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

-(void) addImageData: (NSNotification *)notification
{
//	NSLog(@"AddImageData");
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	RMTileImage *image = (RMTileImage*)[notification object];
	[[RMTileCacheDAO sharedManager] addData:data LastUsed:[image lastUsedTime] ForTile:RMTileHash([image tile])];
	
//	NSLog(@"%d items in DB", [[DAO sharedManager] count]);

}

-(RMTileImage*) cachedImage:(RMTile)tile
{
//	NSLog(@"Looking for cached image in DB");
	
	NSData *data = [[RMTileCacheDAO sharedManager] dataForTile:RMTileHash(tile)];
	if (data == nil)
		return nil;
	
	RMTileImage *image = [RMTileImage imageWithTile:tile FromData:data];
//	NSLog(@"DB cache hit for tile %d %d %d", tile.x, tile.y, tile.zoom);
	return image;
}
/*
+(void) install
{
	if (installed)
		return;
	
	RMDatabaseCache *dbCache = [[RMDatabaseCache alloc] init];
	[[RMTileCache sharedCache] addCache:dbCache];
	[dbCache release];
	
	installed = YES;
}*/

@end
