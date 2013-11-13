//
//  BSONParser.h
//  Graffiti
//
//  Created by Ade on 8/21/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSONDocument.h"

@interface BSONParser : NSObject

- (NSMutableArray *) parseBSONFiles : (NSArray *) documents;

@end
