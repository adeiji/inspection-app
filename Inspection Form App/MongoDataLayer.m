//
//  MongoDataLayer.m
//  Graffiti
//
//  Created by Ade on 8/30/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "MongoDataLayer.h"
#import "MongoDbConnection.h"


@interface MongoDataLayer ()

@end

@implementation MongoDataLayer

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (void) insertData:(NSDictionary *)dataToEnter
          tableName:(NSString *)tableName
{
    //Insert the data into the MongoDb Table
    [MongoDbConnection insertInfo:dataToEnter collectionName:tableName];
}

+ (id) getValues :(NSString *) valueToGet
              keyPathToSearch:(NSString *) keyPathToSearch
               collectionName:(NSString *) collectionName

{
    return [MongoDbConnection getValues:valueToGet keyPathToSearch:keyPathToSearch collectionName:collectionName];
    
}

@end
