//
//  DAO.h
//  CatchMe
//
//  Created by Joseph Gentle on 21/07/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMDatabase;

@interface RMTileCacheDAO : NSObject {
	FMDatabase* db;	
}

-(id) initWithDatabase: (NSString*)path;

-(NSUInteger) count;
-(NSData*) dataForTile: (uint64_t) tileHash;
-(void) touchTile: (uint64_t) tileHash;
-(void) addData: (NSData*) data LastUsed: (NSDate*)date ForTile: (uint64_t) tileHash;
-(void) removeOldestFromDatabase;

//-(NSArray*) getLocalTimetableInformationAt: (int)stopId;

@end
