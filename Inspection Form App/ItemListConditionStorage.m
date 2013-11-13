//
//  ItemListConditionStorage.m
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ItemListConditionStorage.h"
#import "Condition.h"

@implementation ItemListConditionStorage
@synthesize myConditions;

- (id) init:(NSMutableArray *) input {
    if (self = [super init]) {
        myConditions = [[NSMutableArray alloc] init];
        [self fillConditions:input];
    }
    return  self;
}

-(void)fillConditions:(NSMutableArray *)input {
    
    for (int i=0; i<input.count; i++) {
        Condition *myCondition = [[Condition alloc] init];
        [myConditions addObject:myCondition];
    }
}
- (Condition *)getCondition:(int)input {
    return (Condition*)[myConditions objectAtIndex:input];
}
- (void) setCondition :(int)input
            Condition : (Condition *) myCondition {
    [[myConditions objectAtIndex:input] setDeficient:myCondition.deficient];
    [[myConditions objectAtIndex:input] setNotes:myCondition.notes];
    [[myConditions objectAtIndex:input] setDeficientPart:myCondition.deficientPart];
    [[myConditions objectAtIndex:input] setPickerSelection:myCondition.pickerSelection];
    [[myConditions objectAtIndex:input] setApplicable:myCondition.applicable];
}

@end
