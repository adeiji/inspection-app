//
//  Condition.m
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Condition.h"

@implementation Condition

- (id) init {
    if (self = [super init]) {
        _deficient = NO;
        _applicable = NO;
        _notes = [[NSString alloc] init];
        _notes = @"";
        _pickerSelection = 0;
        _deficientPart = nil;
        _optionLocation = 0;
    }
    return self;
}
- (Condition *) initWithParameters : (NSString *) myNotes
                       Defficiency : (BOOL) myDeficient
                   PickerSelection : (NSUInteger *) myPickerSelection
                     DeficientPart : (NSString *) myDeficientPart
                        Applicable : (BOOL) myApplicable
{
    if (self=[super init]) {
        _notes = [[NSString alloc] initWithString:myNotes];
        _deficient = myDeficient;
        _pickerSelection = myPickerSelection;
        _deficientPart = myDeficientPart;
        _applicable = myApplicable;
    }
    return self;
}

@end
