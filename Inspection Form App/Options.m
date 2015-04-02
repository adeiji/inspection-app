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

- (id) initWithPart : (NSString*) part
{
    if (self = [super init]) {
        __optionsArray = [[NSMutableArray alloc] init];
    }
    [self addOptions:part];
    
    return self;
}

- (NSMutableArray*) myOptionsArray {
    return __optionsArray;
}

// This method fills the options
- (void) addOptions : (NSString *) searchValue
{
    // Here's our point of attack
    __optionsArray  = [NSMutableArray arrayWithObjects:@"1", @"2", @"1", @"2", @"1", @"2", @"1", @"2", @"1", @"2", nil];

}

-(void) setMyOptionsArray:(NSMutableArray *)input {
    __optionsArray = input;
}

@end
