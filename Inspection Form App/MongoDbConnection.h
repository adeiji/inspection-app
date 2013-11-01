//
//  MongoDbConnection.h
//  Graffiti
//
//  Created by Ade on 8/19/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjCMongoDB.h"

@interface MongoDbConnection : NSObject

@property (nonatomic, retain) MongoConnection *dbConn;
@property (nonatomic, retain) MongoDBCollection *collection;

//Insert the login information along with the device
- (void) insertCredential : (NSString *) userName
                          : (NSString *) password
                          : (NSString *) device;
- (NSArray *) getAllValuesFromTable;
- (void) changeUserName : (NSString*) oldUserName : (NSString *) newUserName;
- (void) setUpConnection : (NSString *) collectionName;\
- (void) changeValue : (NSDictionary *) oldValue : (NSDictionary *) newValue;
+ (NSDictionary *) getValues :(NSString *) valueToGet
              keyPathToSearch:(NSString *) keyPathToSearch
               collectionName:(NSString *) collectionName;
//Takes a dictionary of info and inputs it into the specified collection of the mongo database
+ (void) insertInfo : (NSDictionary *) dataToEnter
      collectionName:(NSString *) collectionName;

@end
