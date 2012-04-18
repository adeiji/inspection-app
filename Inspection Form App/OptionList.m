//
//  Option.m
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionList.h"

@implementation OptionList

- (id) init {
    if (self = [super init]) {
        theOptionList = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray*) theOptionList {
    return theOptionList;
}
- (void) setOption:(NSMutableArray *)input {
    theOptionList = input;
}
- (void) addOption:(NSString *)input {
    [theOptionList addObject:input];
}

@end
