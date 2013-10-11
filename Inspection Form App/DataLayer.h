//
//  DataLayer.h
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"


@interface DataLayer : NSObject

+ (void) createTable : (NSString*) databasePath
           contactDb : (sqlite3*) contactDB;

+ (NSString*) LoadOwner : (NSString*) databasePath
         contactDb : (sqlite3*) contactDB;
@end
