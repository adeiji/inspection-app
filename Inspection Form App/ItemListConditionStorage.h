//
//  ItemListConditionStorage.h
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Condition.h"
#import "IACraneInspectionDetailsManager.h"
#import "InspectedCrane.h"
#import <Parse/Parse.h>

@interface ItemListConditionStorage : NSObject

@property NSMutableArray *myConditions;

- (id) init:(NSMutableArray *) input;
- (void)fillConditions:(NSMutableArray *) input;
- (NSMutableArray *)getCondition:(int)input;
- (void) setCondition : (int) input
            Condition : (Condition *) myCondition;
- (void) loadConditionsForCrane : (InspectedCrane *) crane;
- (void) loadConditionsForCraneFromServer : (PFObject *) crane
                       WithInspectedCrane : (InspectedCrane *) inspectedCrane;

@end
