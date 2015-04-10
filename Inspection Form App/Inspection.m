//
//  Inspection.m
//  Inspection Form App
//
//  Created by Ade on 10/14/13.
//
//

#import "Inspection.h"

@implementation Inspection

@synthesize customer;
@synthesize inspectedCrane;
@synthesize itemList;

- (id) init {
    if (self = [super init])
    {
        _loadRatings = @"";
        _testLoad = @"";
        _remarksLimitations = @"";
        _proofLoad = @"";
    }
    
    return self;
}

@end
