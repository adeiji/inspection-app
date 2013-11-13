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
        deficient = NO;
        applicable = NO;
        notes = [[NSString alloc] init];
        notes = @"";
        pickerSelection = 0;
        deficientPart = @"";
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
        notes = [[NSString alloc] initWithString:myNotes];
        deficient = myDeficient;
        pickerSelection = myPickerSelection;
        deficientPart = myDeficientPart;
        applicable = myApplicable;
    }
    return self;
}

- (NSString *)notes {
    return notes;
}
- (BOOL) deficient {
    return deficient;
}
- (NSUInteger *) pickerSelection {
    return pickerSelection;
}
- (NSString *) deficientPart {
    return deficientPart;
}
- (BOOL) applicable {
    return applicable;
}
- (void) setNotes:(id)input {
    notes = input;
}
- (void) setDeficient:(BOOL)input {
    deficient = input;
}
- (void) setPickerSelection:(NSUInteger *)input {
    pickerSelection = input;
}
- (void) setDeficientPart:(NSString *)input {
    deficientPart = input;
}
- (void) setApplicable:(BOOL) input {
    applicable = input;
}
@end
