//
//  PFCrane.m
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import "PFCrane.h"

@implementation PFCrane

@dynamic capacity;
@dynamic craneDescription;
@dynamic craneSrl;
@dynamic equipmentNumber;
@dynamic hoistMdl;
@dynamic hoistMfg;
@dynamic hoistSrl;
@dynamic mfg;
@dynamic type;
@dynamic customer;

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"InspectedCrane";
}

@end
