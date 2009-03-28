//
//  RMDatabaseCache.m
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
		NSString *filename = [NSString stringWithFormat:@"Map%@.sqlite", [source uniqueTilecacheKey]];
		
		return [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
	}
	return nil;
}

-(id) initWithDatabase: (NSString*)path
{
	if (![super init])
		return nil;
	
	//	RMLog(@"%d items in DB", [[DAO sharedManager] count]);
	
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
	
		[dao addData:data LastUsed:[image lastUsedTime] ForTile:RMTileKey([image tile])];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:RMMapImageLoadedNotification
												  object:image];
	
	
//	RMLog(@"%d items in DB", [dao count]);
}

-(RMTileImage*) cachedImage:(RMTile)tile
{
//	RMLog(@"Looking for cached image in DB");

	NSData *data = nil;
	
	@synchronized (self) {
	
		data = [dao dataForTile:RMTileKey(tile)];
		if (data == nil)
			return nil;
	
		if (capacity != 0 && purgeStrategy == RMCachePurgeStrategyLRU) {
			[dao touchTile: RMTileKey(tile) withDate: [NSDate date]];
		}
		
	}
	
	RMTileImage *image = [RMTileImage imageWithTile:tile FromData:data];
//	RMLog(@"DB cache hit for tile %d %d %d", tile.x, tile.y, tile.zoom);
	return image;
}

-(void)didReceiveMemoryWarning
{
	LogMethod();
	if (self.databasePath==nil) {
		RMLog(@"unknown db path, unable to reinitialize dao!");
		return;
	}

	@synchronized (self) {
		[dao release];
		dao = [[RMTileCacheDAO alloc] initWithDatabase:self.databasePath];
	}

}

@end
