//
//  PFCustomer.m
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import "PFCustomer.h"

@implementation PFCustomer

@dynamic name;
@dynamic contact;
@dynamic address;
@dynamic email;
@dynamic fromUser;

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Customer";
}

@end

