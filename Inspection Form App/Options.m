//
//  Options.m
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Options.h"
#import "OptionList.h"

@implementation Options

@synthesize optionsArray = __optionsArray;

- (id) init         : (NSString*) typeOfCrane
  OptionsDictionary : (NSDictionary *) optionsDictionary
{
    if (self = [super init]) {
        __optionsArray = [[NSMutableArray alloc] init];
    }
    [self addOptionsFromMongo:typeOfCrane OptionsDictinoary:optionsDictionary];
    
    return self;
}

- (NSMutableArray*) myOptionsArray {
    return __optionsArray;
}

- (void) addOptionsFromMongo : (NSString *) searchValue
           OptionsDictinoary : (NSDictionary *) optionsDictionary
{
    [optionsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id options, BOOL *stop) {
        if ([key isEqualToString:searchValue])
        {
            for (int i = 0; i < [options count]; i++) {
                [__optionsArray addObject:options[i]];
            }
        }
    }];
}

-(void) setMyOptionsArray:(NSMutableArray *)input {
    __optionsArray = input;
}

@end
