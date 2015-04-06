//
//  Parts.m
//  Inspection Form App
//
//  Created by Developer on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Parts.h"
#import "AppDelegate.h"

@implementation Parts
@synthesize myParts;

#define TYPE_COL @"type"
#define PART_COL @"part"
#define PART_NAME_COL @"partName"

- (id) init : (InspectionCrane *) crane {
    if (self = [super init])
    {
        myParts = [NSMutableArray array];
    }
    [self fillPartsFromCrane:crane];
    return self;
}

- myParts {
    return myParts;
}

- (void)setMyParts:(NSMutableArray *)input {
    myParts = input;
}


- (void) fillPartsFromCrane : (InspectionCrane *) crane {
    [myParts addObjectsFromArray:[crane.inspectionPoints allObjects] ];
}
@end
