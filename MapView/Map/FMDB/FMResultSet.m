#import "FMResultSet.h"
#import "FMDatabase.h"

@interface FMResultSet (Private)
- (NSMutableDictionary *)columnNameToIndexMap;
- (void)setColumnNameToIndexMap:(NSMutableDictionary *)value;
@end

@implementation FMResultSet

+ (id) resultSetWithStatement:(FMStatement *)statement usingParentDatabase:(FMDatabase*)aDB {
    
    FMResultSet *rs = [[FMResultSet alloc] init];
    
    [rs setStatement:statement];
    [rs setParentDB:aDB];
    
    return [rs autorelease];
}

- (void)dealloc {
    [self close];
    
    [query release];
    query = nil;
    
    [columnNameToIndexMap release];
    columnNameToIndexMap = nil;
    
	[super dealloc];
}

- (void) close {
    
    [statement reset];
    [statement release];
    statement = nil;
    
    // we don't need this anymore... (i think)
    //[parentDB setInUse:NO];
    parentDB = nil;
}

- (void) setupColumnNames {
    
    if (!columnNameToIndexMap) {
        [self setColumnNameToIndexMap:[NSMutableDictionary dictionary]];
    }	
    
    int columnCount = sqlite3_column_count(statement.statement);
    
    int columnIdx = 0;
    for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
        [columnNameToIndexMap setObject:[NSNumber numberWithInt:columnIdx]
                                 forKey:[[NSString stringWithUTF8String:sqlite3_column_name(statement.statement, columnIdx)] lowercaseString]];
    }
    columnNamesSetup = YES;
}

- (void) kvcMagic:(id)object {
    
    
    int columnCount = sqlite3_column_count(statement.statement);
    
    int columnIdx = 0;
    for (columnIdx = 0; columnIdx < columnCount; columnIdx++) {
        
        
        const char *c = (const char *)sqlite3_column_text(statement.statement, columnIdx);
        
        // check for a null row
        if (c) {
            NSString *s = [NSString stringWithUTF8String:c];
            
            [object setValue:s forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement.statement, columnIdx)]];
        }
    }
}

- (BOOL) next {
    
    int rc;
    BOOL retry;
    int numberOfRetries = 0;
    do {
        retry = NO;
        
        rc = sqlite3_step(statement.statement);
        
        if (SQLITE_BUSY == rc) {
            // this will happen if the db is locked, like if we are doing an update or insert.
            // in that case, retry the step... and maybe wait just 10 milliseconds.
            retry = YES;
            usleep(20);
            
            if ([parentDB busyRetryTimeout] && (numberOfRetries++ > [parentDB busyRetryTimeout])) {
                
                NSLog(@"%s:%d Database busy (%@)", __FUNCTION__, __LINE__, [parentDB databasePath]);
                NSLog(@"Database busy");
                break;
            }
        }
        else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
            // all is well, let's return.
        }
        else if (SQLITE_ERROR == rc) {
            NSLog(@"Error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([parentDB sqliteHandle]));
            break;
        } 
        else if (SQLITE_MISUSE == rc) {
            // uh oh.
            NSLog(@"Error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([parentDB sqliteHandle]));
            break;
        }
        else {
            // wtf?
            NSLog(@"Unknown error calling sqlite3_step (%d: %s) rs", rc, sqlite3_errmsg([parentDB sqliteHandle]));
            break;
        }
        
    } while (retry);
    
    
    if (rc != SQLITE_ROW) {
        [self close];
    }
    
    return (rc == SQLITE_ROW);
}

- (int) columnIndexForName:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    columnName = [columnName lowercaseString];
    
    NSNumber *n = [columnNameToIndexMap objectForKey:columnName];
    
    if (n) {
        return [n intValue];
    }
    
    NSLog(@"Warning: I could not find the column named '%@'.", columnName);
    
    return -1;
}



- (int) intForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return 0;
    }
    
    return sqlite3_column_int(statement.statement, columnIdx);
}
- (int) intForColumnIndex:(int)columnIdx {
    return sqlite3_column_int(statement.statement, columnIdx);
}

- (long) longForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return 0;
    }
    
    return (long)sqlite3_column_int64(statement.statement, columnIdx);
}

- (long) longForColumnIndex:(int)columnIdx {
    return (long)sqlite3_column_int64(statement.statement, columnIdx);
}

- (long long int) longLongIntForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return 0;
    }
    
    return sqlite3_column_int64(statement.statement, columnIdx);
}

- (long long int) longLongIntForColumnIndex:(int)columnIdx {
    return sqlite3_column_int64(statement.statement, columnIdx);
}

- (BOOL) boolForColumn:(NSString*)columnName {
    return ([self intForColumn:columnName] != 0);
}

- (BOOL) boolForColumnIndex:(int)columnIdx {
    return ([self intForColumnIndex:columnIdx] != 0);
}

- (double) doubleForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return 0;
    }
    
    return sqlite3_column_double(statement.statement, columnIdx);
}

- (double) doubleForColumnIndex:(int)columnIdx {
    return sqlite3_column_double(statement.statement, columnIdx);
}


#pragma mark string functions

- (NSString*) stringForColumnIndex:(int)columnIdx {
    
    const char *c = (const char *)sqlite3_column_text(statement.statement, columnIdx);
    
    if (!c) {
        // null row.
        return nil;
    }
    
    return [NSString stringWithUTF8String:c];
}

- (NSString*) stringForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return nil;
    }
    
    return [self stringForColumnIndex:columnIdx];
}




- (NSDate*) dateForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumn:columnName]];
}

- (NSDate*) dateForColumnIndex:(int)columnIdx {
    return [NSDate dateWithTimeIntervalSince1970:[self doubleForColumnIndex:columnIdx]];
}


- (NSData*) dataForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return nil;
    }
    
    
    return [self dataForColumnIndex:columnIdx];
}

- (NSData*) dataForColumnIndex:(int)columnIdx {
    
    int dataSize = sqlite3_column_bytes(statement.statement, columnIdx);
    
    NSMutableData *data = [NSMutableData dataWithLength:dataSize];
    
    memcpy([data mutableBytes], sqlite3_column_blob(statement.statement, columnIdx), dataSize);
    
    return data;
}


- (NSData*) dataNoCopyForColumn:(NSString*)columnName {
    
    if (!columnNamesSetup) {
        [self setupColumnNames];
    }
    
    int columnIdx = [self columnIndexForName:columnName];
    
    if (columnIdx == -1) {
        return nil;
    }
    
    
    return [self dataNoCopyForColumnIndex:columnIdx];
}

- (NSData*) dataNoCopyForColumnIndex:(int)columnIdx {
    
    int dataSize = sqlite3_column_bytes(statement.statement, columnIdx);
    
    NSData *data = [NSData dataWithBytesNoCopy:(void *)sqlite3_column_blob(statement.statement, columnIdx) length:dataSize freeWhenDone:NO];
    
    return data;
}





- (void)setParentDB:(FMDatabase *)newDb {
    parentDB = newDb;
}


- (NSString *)query {
    return query;
}

- (void)setQuery:(NSString *)value {
    [value retain];
    [query release];
    query = value;
}

- (NSMutableDictionary *)columnNameToIndexMap {
    return columnNameToIndexMap;
}

- (void)setColumnNameToIndexMap:(NSMutableDictionary *)value {
    [value retain];
    [columnNameToIndexMap release];
    columnNameToIndexMap = value;
}

- (FMStatement *) statement {
    return statement;
}

- (void)setStatement:(FMStatement *)value {
    if (statement != value) {
        [statement release];
        statement = [value retain];
    }
}



@end
