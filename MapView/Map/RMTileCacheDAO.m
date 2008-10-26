//
//  DAO.m
//  CatchMe
//
//  Created by Joseph Gentle on 21/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RMTileCacheDAO.h"
#import "FMDatabase.h"
#import "RMTileCache.h"
#import "RMTileImage.h"

static RMTileCacheDAO *sharedDAOManager = nil;

@implementation RMTileCacheDAO

-(void)configureDBForFirstUse
{
	// [db executeUpdate:@"DROP TABLE ZCACHE"];
	[db executeUpdate:@"CREATE TABLE IF NOT EXISTS ZCACHE (ztileHash INTEGER PRIMARY KEY, zlastUsed DATE, zdata BLOB)"];
}

- (NSString*)dbPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		// only copying one file
		return [[paths objectAtIndex:0]  stringByAppendingPathComponent:@"Map.sqlite"];
	}
	return nil;
}

- (id)init
{
	if (![super init])
		return nil;

	NSString *path = [self dbPath];
	NSLog(@"Opening database at %@", path);
	
	db = [[FMDatabase alloc] initWithPath:path];
	if (![db open])
	{
		NSLog(@"Could not connect to database - %@", [db lastErrorMessage]);
//		return nil;
	}
	
	[db setCrashOnErrors:TRUE];
	
	[self configureDBForFirstUse];
	
	return self;
}

- (void)dealloc
{
	[db release];
	[super dealloc];
}


-(NSUInteger) count
{
	FMResultSet *results = [db executeQuery:@"SELECT COUNT(ztileHash) FROM ZCACHE"];
	
	int count = 0;
	
	if ([results next])
		count = [results intForColumnIndex:0];
	else
	{
		NSLog(@"Unable to count columns");
	}
	
	[results close];
	
	return count;
}

-(NSData*) dataForTile: (uint64_t) tileHash
{
	FMResultSet *results = [db executeQuery:@"SELECT zdata FROM ZCACHE WHERE ztilehash = ?", [NSNumber numberWithUnsignedLongLong:tileHash]];
	
	if ([db hadError])
	{
		NSLog(@"DB error while fetching tile data: %@", [db lastErrorMessage]);
		return nil;
	}
	
	NSData *data = nil;
	
	if ([results next])
	{
		data = [results dataForColumnIndex:0];
	}
	
	[results close];
	
	return data;
}
-(void) removeOldestFromDatabase
{
	
}
-(void) touchTile: (uint64_t) tileHash
{
	
}
-(void) addData: (NSData*) data LastUsed: (NSDate*)date ForTile: (uint64_t) tileHash
{
	// Fixme
//	NSLog(@"addData\t%d", tileHash);
	BOOL result = [db executeUpdate:@"INSERT OR IGNORE INTO ZCACHE (ztileHash, zlastUsed, zdata) VALUES (?, ?, ?)", [NSNumber numberWithUnsignedLongLong:tileHash], date, data];
	if (result == NO)
	{
		NSLog(@"Error occured adding data");
	}
//	NSLog(@"done\t%d", tileHash);
}



// Singleton gunk as per CocoaFundamentals page 99.
+ (RMTileCacheDAO*)sharedManager 
{ 
	@synchronized(self) { 
		if (sharedDAOManager == nil) { 
			[[self alloc] init]; // assignment not done here 
		} 
	} 
	return sharedDAOManager; 
} 
+ (id)allocWithZone:(NSZone *)zone 
{ 
	@synchronized(self) { 
		if (sharedDAOManager == nil) { 
			sharedDAOManager = [super allocWithZone:zone]; 
			return sharedDAOManager; // assignment and return on first allocation 
		} 
	} 
	return nil; //on subsequent allocation attempts return nil 
} 
- (id)copyWithZone:(NSZone *)zone 
{ 
	return self; 
} 
- (id)retain 
{ 
	return self; 
} 
- (unsigned)retainCount 
{ 
	return UINT_MAX; //denotes an object that cannot be released 
} 
- (void)release 
{
	//do nothing 
} 
- (id)autorelease 
{ 
	return self; 
}


@end
