//
//  InspectionBussiness.m
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import "InspectionBussiness.h"


@implementation InspectionBussiness

+ (void) removeFromDatastoreTable : (DBAccount *) account
                            Query : (NSDictionary *) query
                        Datastore : (DBDatastore *) dataStore
                            Table : (DBTable *) table
{
    //Remove the records that match the specified query fromt he database
    [DataLayer removeFromDatastoreTable:query DBAccount:account DBDatastore:dataStore DBTable:table];
}

//Adds the record to the database.  Adds the record with the corresponding date, that way we can pull previous orders by date.
+ (void) insertToDatastoreTable : (DBAccount*) account
                      DataStore : (DBDatastore *) dataStore
                          Table : (DBTable *) table
                      TableName : (NSString *) tableName
                DictionaryToAdd : (NSDictionary *) dictionaryToAdd
{
        
        //Add this condition to the datastore
        [DataLayer insertToDatastoreTable:dictionaryToAdd TableName:tableName DBAccount:account DBDatastore:dataStore DBTable:table];
}

+ (NSArray*) getRecords : (NSDictionary*) dictionaryQuery
              DBAccount : (DBAccount *) account
            DBDatastore : (DBDatastore *) dataStore
                DBTable : (DBTable *) table
{
    return [DataLayer getRecords:dictionaryQuery DBAccount:account DBDatastore:dataStore DBTable:table];
}

//Inserts a customer into the dropbox datastore jobs table
+ (void) InsertCustomerIntoTable : (Customer*) customer
{
    
}

+ (Customer*) createCustomer : (NSString*) customerName
        CustomerContact : (NSString*) customerContact
        CustomerAddress : (NSString*) customerAddress
          CustomerEmail : (NSString*) customerEmail
{
    Customer *customer = [[Customer alloc] init];
    
    customer.name       = customerName;
    customer.contact    = customerContact;
    customer.address    = customerAddress;
    customer.email      = customerEmail;
    
    return customer;
}

//Create a crane object and send it to the recipient
+ (Crane*) createCrane : (NSString*) hoistSrl
           CraneType : (NSString*) craneType
     EquipmentNumber : (NSString*) equipmentNumber
            CraneMfg : (NSString*) craneMfg
            hoistMfg : (NSString*) hoistMfg
            CraneSrl : (NSString*) craneSrl
            Capacity : (NSString*) capacity
            HoistMdl : (NSString*) hoistMdl
{
    Crane *crane = [[Crane alloc] init];
    
    crane.hoistSrl          = hoistSrl;
    crane.type              = craneType;
    crane.equipmentNumber   = equipmentNumber;
    crane.mfg               = craneMfg;
    crane.hoistMfg          = hoistMfg;
    crane.craneSrl          = craneSrl;
    crane.capacity          = capacity;
    crane.hoistMdl          = hoistMdl;
    
    return crane;
}

@end