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

@implementation RMDatabaseCache

@synthesize databasePath;

+ (NSString*)dbPathForTileSource: (id<RMTileSource>) source usingCacheDir: (BOOL) useCacheDir
{
	NSArray *paths;
	
	if (useCacheDir) {
		paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	} else {
		paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	}
	
	if ([paths count] > 0) // Should only be one...
	{
		NSString *filename = [NSString stringWithFormat:@"Map%@.sqlite", [source description]];
		
		return [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
	}
	return nil;
}

-(id) initWithDatabase: (NSString*)path
{
	if (![super init])
		return nil;
	
	//	NSLog(@"%d items in DB", [[DAO sharedManager] count]);
	
	self.databasePath = path;
	dao = [[RMTileCacheDAO alloc] initWithDatabase:path];

	if (dao == nil)
		return nil;
	
	return self;	
}

-(id) initWithTileSource: (id<RMTileSource>) source usingCacheDir: (BOOL) useCacheDir
{
	return [self initWithDatabase:[RMDatabaseCache dbPathForTileSource:source usingCacheDir: useCacheDir]];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[databasePath release];
	[dao release];
	
	[super dealloc];
}

-(void) setPurgeStrategy: (RMCachePurgeStrategy) theStrategy
{
	purgeStrategy = theStrategy;
}

-(void) setCapacity: (NSUInteger) theCapacity
{
	capacity = theCapacity;
}

-(void) setMinimalPurge: (NSUInteger) theMinimalPurge
{
	minimalPurge = theMinimalPurge;
}

-(void)addTile: (RMTile)tile WithImage: (RMTileImage*)image
{
	// The tile probably hasn't loaded any data yet... we must be patient.
	// However, if the image is already loaded we probably don't need to cache it.
	
	// This will be the case for any other web caches which are active.
	if (![image isLoaded])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(addImageData:)
													 name:RMMapImageLoadedNotification
												   object:image];
	}
}

-(void) addImageData: (NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:@"data"];
	RMTileImage *image = (RMTileImage*)[notification object];
	
	@synchronized (self) {

		if (capacity != 0) {
			NSUInteger tilesInDb = [dao count];
			if (capacity <= tilesInDb) {
				[dao purgeTiles: MAX(minimalPurge, 1+tilesInDb-capacity)];
			}
		}
	
		[dao addData:data LastUsed:[image lastUsedTime] ForTile:RMTileHash([image tile])];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:RMMapImageLoadedNotification
												  object:image];
	
	
//	NSLog(@"%d items in DB", [dao count]);
}

-(RMTileImage*) cachedImage:(RMTile)tile
{
//	NSLog(@"Looking for cached image in DB");

	NSData *data = nil;
	
	@synchronized (self) {
	
		data = [dao dataForTile:RMTileHash(tile)];
		if (data == nil)
			return nil;
	
		if (capacity != 0 && purgeStrategy == RMCachePurgeStrategyLRU) {
			[dao touchTile: RMTileHash(tile) withDate: [NSDate date]];
		}
		
	}
	
	RMTileImage *image = [RMTileImage imageWithTile:tile FromData:data];
//	NSLog(@"DB cache hit for tile %d %d %d", tile.x, tile.y, tile.zoom);
	return image;
}

-(void)didReceiveMemoryWarning
{
	if (self.databasePath==nil) {
		NSLog(@"unknown db path, unable to reinitialize dao!");
		return;
	}

	@synchronized (self) {
		[dao release];
		dao = [[RMTileCacheDAO alloc] initWithDatabase:self.databasePath];
	}

}

@end
