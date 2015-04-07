//
//  InspectionBussiness.h
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>
#import "DataLayer.h"
#import "ItemListConditionStorage.h"
#import "Inspection.h"
#import "Parts.h"
#import "Customer.h"

@interface InspectionBussiness : NSObject

+ (void) removeFromDatastoreTable : (DBAccount *) account
                            Query : (NSDictionary *) query
                        Datastore : (DBDatastore *) dataStore
                            Table : (DBTable *) table;

+ (void) insertToDatastoreTable : (DBAccount*) account
                      DataStore : (DBDatastore *) dataStore
                          Table : (DBTable *) table
                      TableName : (NSString *) tableName
                DictionaryToAdd : (NSDictionary *) dictionaryToAdd;

+ (NSArray*) getRecords : (NSDictionary*) dictionaryQuery
              DBAccount : (DBAccount *) account
            DBDatastore : (DBDatastore *) dataStore
                DBTable : (DBTable *) table;

+ (void) InsertCustomerIntoTable : (Customer*) customer;

+ (Customer*) createCustomer : (NSString*) customerName
        CustomerContact : (NSString*) customerContact
        CustomerAddress : (NSString*) customerAddress
          CustomerEmail : (NSString*) customerEmail;


@end
