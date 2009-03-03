#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // delete the old db.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeFileAtPath:@"/tmp/tmp.db" handler:nil];
    
    FMDatabase* db = [FMDatabase databaseWithPath:@"/tmp/tmp.db"];
    if (![db open]) {
        NSLog(@"Could not open db.");
        [pool release];
        return 0;
    }
    
    // kind of experimentalish.
    [db setShouldCacheStatements:YES];
    
    // create a bad statement, just to test the error code.
    [db executeUpdate:@"blah blah blah"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    // but of course, I don't bother checking the error codes below.
    // Bad programmer, no cookie.
    
    [db executeUpdate:@"create table test (a text, b text, c integer, d double, e double)"];
    
    
    [db beginTransaction];
    int i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
            @"hi'", // look!  I put in a ', and I'm not escaping it!
            [NSString stringWithFormat:@"number %d", i],
            [NSNumber numberWithInt:i],
            [NSDate date],
            [NSNumber numberWithFloat:2.2f]];
    }
    [db commit];
    
    
    
    // do it again, just because
    [db beginTransaction];
    i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
         @"hi again'", // look!  I put in a ', and I'm not escaping it!
         [NSString stringWithFormat:@"number %d", i],
         [NSNumber numberWithInt:i],
         [NSDate date],
         [NSNumber numberWithFloat:2.2f]];
    }
    [db commit];
    
    
    
    
    
    FMResultSet *rs = [db executeQuery:@"select rowid,* from test where a = ?", @"hi'"];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSLog(@"%d %@ %@ %@ %@ %f %f",
              [rs intForColumn:@"c"],
              [rs stringForColumn:@"b"],
              [rs stringForColumn:@"a"],
              [rs stringForColumn:@"rowid"],
              [rs dateForColumn:@"d"],
              [rs doubleForColumn:@"d"],
              [rs doubleForColumn:@"e"]);
    }
    // close the result set.
    // it'll also close when it's dealloc'd, but we're closing the database before
    // the autorelease pool closes, so sqlite will complain about it.
    [rs close];  
    
    // ----------------------------------------------------------------------------------------
    // blob support.
    [db executeUpdate:@"create table blobTable (a text, b blob)"];
    
    // let's read in an image from safari's app bundle.
    NSData *d = [NSData dataWithContentsOfFile:@"/Applications/Safari.app/Contents/Resources/compass.icns"];
    if (d) {
        [db executeUpdate:@"insert into blobTable (a, b) values (?,?)", @"safari's compass", d];
        
        rs = [db executeQuery:@"select b from blobTable where a = ?", @"safari's compass"];
        if ([rs next]) {
            d = [rs dataForColumn:@"b"];
            [d writeToFile:@"/tmp/compass.icns" atomically:NO];
            
            // let's look at our fancy image that we just wrote out..
            system("/usr/bin/open /tmp/compass.icns");
            
            // ye shall read the header for this function, or suffer the consequences.
            d = [rs dataNoCopyForColumn:@"b"];
            [d writeToFile:@"/tmp/compass_data_no_copy.icns" atomically:NO];
            system("/usr/bin/open /tmp/compass_data_no_copy.icns");
        }
        else {
            NSLog(@"Could not select image.");
        }
        
        [rs close];
        
    }
    else {
        NSLog(@"Can't find compass image..");
    }
    
    
    // test out the convenience methods in +Additions
    [db executeUpdate:@"create table t1 (a integer)"];
    [db executeUpdate:@"insert into t1 values (?)", [NSNumber numberWithInt:5]];
    int a = [db intForQuery:@"select a from t1 where a = ?", [NSNumber numberWithInt:5]];
    if (a != 5) {
        NSLog(@"intForQuery didn't work (a != 5)");
    }
    
    // test the busy rety timeout schtuff.
    
    [db setBusyRetryTimeout:50000];
    
    FMDatabase *newDb = [FMDatabase databaseWithPath:@"/tmp/tmp.db"];
    [newDb open];
    
    rs = [newDb executeQuery:@"select rowid,* from test where a = ?", @"hi'"];
    [rs next]; // just grab one... which will keep the db locked.
    
    NSLog(@"Testing the busy timeout");
    
    BOOL success = [db executeUpdate:@"insert into t1 values (5)"];
    
    if (success) {
        NSLog(@"Whoa- the database didn't stay locked!");
        return 7;
    }
    else {
        NSLog(@"Hurray, our timeout worked");
    }
    
    [rs close];
    [newDb close];
    
    success = [db executeUpdate:@"insert into t1 values (5)"];
    if (!success) {
        NSLog(@"Whoa- the database shouldn't be locked!");
        return 8;
    }
    else {
        NSLog(@"Hurray, we can insert again!");
    }
    
    
    
    // test some nullness.
    [db executeUpdate:@"create table t2 (a integer, b integer)"];
    
    if (![db executeUpdate:@"insert into t2 values (?, ?)", nil, [NSNumber numberWithInt:5]]) {
        NSLog(@"UH OH, can't insert a nil value for some reason...");
    }
    
    
    
    
    rs = [db executeQuery:@"select * from t2"];
    while ([rs next]) {
        NSString *a = [rs stringForColumnIndex:0];
        NSString *b = [rs stringForColumnIndex:1];
        
        if (a != nil) {
            NSLog(@"%s:%d", __FUNCTION__, __LINE__);
            NSLog(@"OH OH, PROBLEMO!");
            return 10;
        }
        else {
            NSLog(@"YAY, NULL VALUES");
        }
        
        if (![b isEqualToString:@"5"]) {
            NSLog(@"%s:%d", __FUNCTION__, __LINE__);
            NSLog(@"OH OH, PROBLEMO!");
            return 10;
        }
    }
    
    
    
    
    
    
    
    
    
    
    // test some inner loop funkness.
    [db executeUpdate:@"create table t3 (a somevalue)"];
    
    
    // do it again, just because
    [db beginTransaction];
    i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into t3 (a) values (?)" , [NSNumber numberWithInt:i]];
    }
    [db commit];
    
    
    
    
    rs = [db executeQuery:@"select * from t3"];
    while ([rs next]) {
        int foo = [rs intForColumnIndex:0];
        
        int newVal = foo + 100;
        
        [db executeUpdate:@"update t3 set a = ? where a = ?" , [NSNumber numberWithInt:newVal], [NSNumber numberWithInt:foo]];
        
        
        FMResultSet *rs2 = [db executeQuery:@"select a from t3 where a = ?", [NSNumber numberWithInt:newVal]];
        [rs2 next];
        
        if ([rs2 intForColumnIndex:0] != newVal) {
            NSLog(@"Oh crap, our update didn't work out!");
            return 9;
        }
        
        [rs2 close];
    }
    
    
    // NSNull tests
    [db executeUpdate:@"create table nulltest (a text, b text)"];
    
    [db executeUpdate:@"insert into nulltest (a, b) values (?, ?)" , [NSNull null], @"a"];
    [db executeUpdate:@"insert into nulltest (a, b) values (?, ?)" , nil, @"b"];
    
    rs = [db executeQuery:@"select * from nulltest"];
    
    while ([rs next]) {
        
        NSString *a = [rs stringForColumnIndex:0];
        NSString *b = [rs stringForColumnIndex:1];
        
        if (!b) {
            NSLog(@"Oh crap, the nil / null inserts didn't work!");
            return 10;
        }
        
        if (a) {
            NSLog(@"Oh crap, the nil / null inserts didn't work (son of error message)!");
            return 11;
        }
        else {
            NSLog(@"HURRAH FOR NSNULL (and nil)!");
        }
    }
    
    // print out some stats if we are using cached statements.
    if ([db shouldCacheStatements]) {
        
        NSEnumerator *e = [[db cachedStatements] objectEnumerator];;
        FMStatement *statement;
        
        while ((statement = [e nextObject])) {
        	NSLog(@"%@", statement);
        }
    }
    NSLog(@"That was version %@ of sqlite", [FMDatabase sqliteLibVersion]);
    
    
    [db close];
    
    [pool release];
    return 0;
}
