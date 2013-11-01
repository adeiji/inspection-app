//
//  MongoDataLayer.h
//  Graffiti
//
//  Created by Ade on 8/30/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MongoDataLayer : NSObject  

+ (void) insertData : (NSDictionary *) dataToEnter
          tableName : (NSString *) tableName;

+ (id) getValues :(NSString *) valueToGet
              keyPathToSearch:(NSString *) keyPathToSearch
               collectionName:(NSString *) collectionName;
@end
