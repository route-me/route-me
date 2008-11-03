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


@implementation RMTileCacheDAO

-(void)configureDBForFirstUse
{
	// [db executeUpdate:@"DROP TABLE ZCACHE"];
	[db executeUpdate:@"CREATE TABLE IF NOT EXISTS ZCACHE (ztileHash INTEGER PRIMARY KEY, zlastUsed DOUBLE, zdata BLOB)"];
}

-(id) initWithDatabase: (NSString*)path
{
	if (![super init])
		return nil;

	NSLog(@"Opening database at %@", path);
	
	db = [[FMDatabase alloc] initWithPath:path];
	if (![db open])
	{
		NSLog(@"Could not connect to database - %@", [db lastErrorMessage]);
		return nil;
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

-(void) purgeTiles: (NSUInteger) count;
{
	NSLog(@"purging %u old tiles from db cache", count);
	
	// does not work: "DELETE FROM ZCACHE ORDER BY zlastUsed LIMIT"

	BOOL result = [db executeUpdate: @"DELETE FROM ZCACHE WHERE ztileHash IN (SELECT ztileHash FROM ZCACHE ORDER BY zlastUsed LIMIT ? )", 
				   [NSNumber numberWithUnsignedInt: count]];
	if (result == NO) {
		NSLog(@"Error purging cache");
	}
	
}

-(void) touchTile: (uint64_t) tileHash withDate: (NSDate*) date
{
	BOOL result = [db executeUpdate: @"UPDATE ZCACHE SET zlastUsed = ? WHERE ztileHash = ? ", 
				   date, [NSNumber numberWithUnsignedInt: tileHash]];
	
	if (result == NO) {
		NSLog(@"Error touching tile");
	}
}

-(void) addData: (NSData*) data LastUsed: (NSDate*)date ForTile: (uint64_t) tileHash
{
	// Fixme
//	NSLog(@"addData\t%d", tileHash);
	BOOL result = [db executeUpdate:@"INSERT OR IGNORE INTO ZCACHE (ztileHash, zlastUsed, zdata) VALUES (?, ?, ?)", 
		[NSNumber numberWithUnsignedLongLong:tileHash], date, data];
	if (result == NO)
	{
		NSLog(@"Error occured adding data");
	}
//	NSLog(@"done\t%d", tileHash);
}

@end
