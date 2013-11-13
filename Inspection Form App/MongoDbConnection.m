//
//  MongoDbConnection.m
//  Graffiti
//
//  Created by Ade on 8/19/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "MongoDbConnection.h"
#import "ObjCMongoDB.h"
#import "NSArray+MongoAdditions.h"
#import "MongoDbTags.h"

@implementation MongoDbConnection

@synthesize dbConn;
@synthesize collection;

//Set the address to the ip of my mac or whatever the ip address is of the server
//#define address @"54.213.167.56"
#define address @"127.0.0.1"
//mac home address - 192.168.1.129

- (void) setUpConnection : (NSString *) collectionName
{
    NSError *error = nil;
    //Create the connection and access the collectionName
    dbConn = [MongoConnection connectionForServer:address error:&error];
    collection = [dbConn collectionWithName:collectionName];
}

+ (void) insertInfo : (NSDictionary *) dataToEnter
      collectionName:(NSString *) collectionName
{
    NSError *error;
    
    [[[MongoConnection connectionForServer:address error:&error] collectionWithName:collectionName ] insertDictionary:dataToEnter writeConcern:nil error:&error];
}


//Receieve the credential information and store it into the mongodb database
- (void) insertCredential : (NSString *) userName
                          : (NSString *) password
                          : (NSString *) device
{
    NSError *error = nil;
    NSDictionary *loginInfo = @{
                                @"userid" : [NSString stringWithFormat:@"\"%@\"", userName],
                                @"password" : [NSString stringWithFormat:@"\"%@\"", password],
                                @"device" : @[
                                        @{
                                            @"device" : [NSString stringWithFormat:@"\"%@\"", device]
                                        }
                                    ]
                                };
    
    [collection insertDictionary:loginInfo writeConcern:nil error:&error];
}

+ (NSArray *) getValues :(NSString *) valueToGet
              keyPathToSearch:(NSString *) keyPathToSearch
               collectionName:(NSString *) collectionName

{
    if ([valueToGet isEqualToString:@"GET_ALL_VALUES"])
    {
        NSError *error = nil;
        MongoDBCollection *collection = [[MongoConnection connectionForServer:address error:&error] collectionWithName:collectionName];
        
        //Gets an array of BSON documents
        NSArray *result = [collection findAllWithError:&error];
        NSLog(@"fetch result: %@", result);
        
        return [collection findAllWithError:&error];
    }
    
    NSError *error = nil;
    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
    [predicate keyPath:keyPathToSearch matches:valueToGet];
    NSArray *result = [[[MongoConnection connectionForServer:address error:&error] collectionWithName:collectionName ] findWithPredicate:predicate error:&error];
    //NSDictionary * result = [BSONDecoder decodeDictionaryWithDocument:resultDoc];
    NSLog(@"fetch result: %@", result);
    
    return result;
}

- (void) changeUserName : (NSString*) oldUserName : (NSString *) newUserName : (NSString *) keyPathToSearch
{
    NSError *error = nil;
    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
    [predicate keyPath:keyPathToSearch matches:oldUserName];
    
    MongoUpdateRequest *updateRequest = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
    [updateRequest keyPath:keyPathToSearch setValue:newUserName];
    
    [collection updateWithRequest:updateRequest error:&error];
    
    BSONDocument *resultDoc = [collection findOneWithPredicate:predicate error:&error];
    NSDictionary *result = [BSONDecoder decodeDictionaryWithDocument:resultDoc];
    NSLog(@"fetch result after update: %@", result);
}

- (void) changeValue : (NSDictionary *) oldValue
                     : (NSDictionary *) newValue
{
    //This dictionary contains all the Column names and dictionaries that contain the old and new values
    for (NSString *columnName in [oldValue allKeys])
    {
        NSError *error = nil;
        MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
        //Set the predicate to search for the given column name with the old value
        [predicate keyPath:columnName matches:[oldValue objectForKey:columnName]];
        
        MongoUpdateRequest *updateRequest = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
        //Update the old value with the new value.
        [updateRequest keyPath:columnName setValue:[newValue objectForKey:columnName]];
        [collection updateWithRequest:updateRequest error:&error];
    }
   
}


@end
