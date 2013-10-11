//
//  DataLayer.m
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import "DataLayer.h"
#import "sqlite3.h"
#import "Customer.h"
#import "Crane.h"
#import <Dropbox/Dropbox.h>

@implementation DataLayer


+ (NSString*) LoadOwner : (NSString*) databasePath
         contactDb : (sqlite3*) contactDB
{
    NSString *owner = [[NSString alloc] init];
    sqlite3_stmt *statement;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    documentsDir = [paths objectAtIndex:0];
    
    //full file location string
    databasePath = [[NSString alloc] initWithString:[documentsDir stringByAppendingPathComponent:@"contacts.db"]];
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
    {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT NAME FROM IPADOWNER"];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *chName = (char*) sqlite3_column_text(statement, 0);
                owner = [NSString stringWithUTF8String:chName];
                
                NSLog(@"Retrieved condition from the table");
                //release memory
                chName = nil;
            }
        }
        else {
            NSLog(@"Failed to find jobnumber in table");
        }
    }
    
    return owner;
}


@end
