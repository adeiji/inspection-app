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

- (id) initWithPart : (InspectionPoint *) inspectionPoint
{
    if (self = [super init]) {
        __optionsArray = [[NSMutableArray alloc] init];
    }
    [self addOptions:inspectionPoint];
    
    return self;
}

- (NSArray *) myOptionsArray {
    return __optionsArray;
}

// This method fills the options
- (void) addOptions : (InspectionPoint *) inspectionPoint
{
    // Here's our point of attack
    __optionsArray  = [
                       inspectionPoint.inspectionOptions allObjects];

}


@end
