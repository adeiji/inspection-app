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

-(void)fillConditions:(NSArray *)input {
    //Add a default condition for every single part that there is.
    for (int i=0; i<input.count; i++) {
        Condition *myCondition = [[Condition alloc] init];
        [myConditions addObject:myCondition];
    }
}
- (Condition *)getCondition:(int)input {
    return (Condition*)[myConditions objectAtIndex:input];
}

- (void) loadConditionsForCrane : (InspectedCrane *) crane {
    
    NSArray *conditions = [[IACraneInspectionDetailsManager sharedManager] getAllConditionsForCrane : crane];
    myConditions = [NSMutableArray new];
    for (CoreDataCondition *coreDataCondition in conditions) {
        Condition *myCondition = [[Condition alloc] init];
        myCondition.notes = coreDataCondition.notes;
        myCondition.pickerSelection = coreDataCondition.optionSelectedIndex;
        myCondition.deficientPart = coreDataCondition.optionSelected;
        myCondition.applicable = coreDataCondition.isApplicable == [NSNumber numberWithInt:1] ? YES : NO;
        myCondition.deficient = coreDataCondition.isDeficient == [NSNumber numberWithInt:1] ? YES : NO;
        [myConditions addObject:myCondition];
    }
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
