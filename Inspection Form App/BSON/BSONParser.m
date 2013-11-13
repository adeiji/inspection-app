//
//  BSONParser.m
//  Graffiti
//
//  Created by Ade on 8/21/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "BSONParser.h"
#import "BSONDocument.h"

@implementation BSONParser

//Gets the dictionary values of all the documents in the given array
- (NSMutableArray *) parseBSONFiles :(NSArray *)documents
{
    NSMutableArray *parsedDocuments = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [documents count]; i++)
    {
        //Gets the dictionary values of the documents
        [parsedDocuments addObject:[[documents objectAtIndex:i] dictionaryValue ]];
    }
    
    return parsedDocuments;
}


@end
