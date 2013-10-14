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

+ (void) insertInspectionToDatastoreTable : (NSArray*) myConditions
                        DictionaryToStore : (NSDictionary*) dictionaryToStore;

+ (void) removeFromDatastoreTable : (NSDictionary*) dictionaryQuery
                        DBAccount : (DBAccount *) account
                      DBDatastore : (DBDatastore *) dataStore
                          DBTable : (DBTable *) table;
+ (void) sync : (DBDatastore*) dataStore;


@property (strong, nonatomic) DBAccount *account;
@property (strong, nonatomic) DBDatastore *inspectionDataStore;
@property (strong, nonatomic) DBTable *inspectionsTable;

@end
