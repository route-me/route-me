#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class FMDatabase;

@interface FMResultSet : NSObject {
    FMDatabase *parentDB;
    sqlite3_stmt *pStmt;
    //sqlite3 *db;
    NSString *query;
    NSMutableDictionary *columnNameToIndexMap;
    BOOL columnNamesSetup;
}

+ (id) resultSetWithStatement:(sqlite3_stmt *)stmt usingParentDatabase:(FMDatabase*)aDB;

- (void) close;

- (NSString *)query;
- (void)setQuery:(NSString *)value;

- (void)setPStmt:(sqlite3_stmt *)newsqlite3_stmt;
- (void)setParentDB:(FMDatabase *)newDb;

- (NSUInteger) columnCount;

- (BOOL) next;

- (int) intForColumn:(NSString*)columnName;
- (int) intForColumnIndex:(int)columnIdx;

- (long) longForColumn:(NSString*)columnName;
- (long) longForColumnIndex:(int)columnIdx;

- (BOOL) boolForColumn:(NSString*)columnName;
- (BOOL) boolForColumnIndex:(int)columnIdx;

- (double) doubleForColumn:(NSString*)columnName;
- (double) doubleForColumnIndex:(int)columnIdx;

- (NSString*) stringForColumn:(NSString*)columnName;
- (NSString*) stringForColumnIndex:(int)columnIdx;

- (NSDate*) dateForColumn:(NSString*)columnName withFormatString:(NSString*)formatString;
- (NSDate*) dateForColumnIndex:(int)columnIdx withFormatString:(NSString*)formatString;

- (NSDate*) dateForColumn:(NSString*)columnName;
- (NSDate*) dateForColumnIndex:(int)columnIdx;

- (NSDate*) timeForColumn:(NSString*)columnName;
- (NSDate*) timeForColumnIndex:(int)columnIdx;
//- (NSDate*) timeForColumn:(NSString*)columnName sinceDate:(NSDate*)date;
//- (NSDate*) timeForColumnIndex:(int)columnIdx sinceDate:(NSDate*)dateOffset;

- (NSData*) dataForColumn:(NSString*)columnName;
- (NSData*) dataForColumnIndex:(int)columnIdx;

- (void) kvcMagic:(id)object;

@end
