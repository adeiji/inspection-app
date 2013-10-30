//
//  DataLayer.h
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import <Dropbox/Dropbox.h>

@interface DataLayer : NSObject

+ (void) createTable : (NSString*) databasePath
           contactDb : (sqlite3*) contactDB;

+ (NSString*) LoadOwner : (NSString*) databasePath
         contactDb : (sqlite3*) contactDB;

+ (void) insertToDatastoreTable : (NSDictionary*) dictionaryToStore
                      TableName : (NSString*) tableName
                      DBAccount : (DBAccount *) account
                    DBDatastore : (DBDatastore *) dataStore
                        DBTable : (DBTable *) table;

+ (void) removeFromDatastoreTable : (NSDictionary*) dictionaryQuery
                        DBAccount : (DBAccount *) account
                      DBDatastore : (DBDatastore *) dataStore
                          DBTable : (DBTable *) table;
+ (void) sync : (DBDatastore*) dataStore;

+ (NSArray*) getRecords : (NSDictionary*) dictionaryQuery
              DBAccount : (DBAccount *) account
            DBDatastore : (DBDatastore *) dataStore
                DBTable : (DBTable *) table;

@property (strong, nonatomic) DBAccount *account;
@property (strong, nonatomic) DBDatastore *inspectionDataStore;
@property (strong, nonatomic) DBTable *inspectionsTable;

@end
