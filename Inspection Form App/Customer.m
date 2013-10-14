//
//  Customer.m
//  Inspection Form App
//
//  Created by Developer on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Customer.h"

@implementation Customer

@synthesize name;
@synthesize contact;
@synthesize address;
@synthesize date;
@synthesize jobNumber;
@synthesize equipDescription;
@synthesize craneMfg;
@synthesize hoistMfg;
@synthesize hoistMdl;
@synthesize hoistSrl;
@synthesize equipmentNumber;
@synthesize email;
@synthesize description;

- (id) init {
    if (self = [super init]) {
        [self setName:@"Default Name"];
    }
    return self;
}

+ (Customer*) customer {
    Customer * newCustomer = [[Customer alloc] init];
    return newCustomer;
}

- (NSString *) name {
    return name;
}

- (NSString *) contact {
    return contact;
}

- (NSString *) address {
    return address;
}

- (NSDate *) date {
    return date;
}

- (NSInteger *) jobNumber {
    return jobNumber;
}

- (NSString *) equipDescription {
    return equipDescription;
}

- (NSString *) craneMfg {
    return craneMfg;
}

- (NSString *) hoistMfg {
    return hoistMfg;
}
- (NSString *) hoistMdl {
    return hoistMdl;
}

- (void) setName: (NSString *)input {
    name = input;
}
- (void) setContact: (NSString *)input {
    contact = input;
}
- (void) setAddress: (NSString *) input {
    address = input;
}
- (void) setDate: (NSDate *)input {
    date = input;
}
- (void) setJobNumber: (NSInteger *)input {
    jobNumber = input;
}
- (void) setEquipDescription: (NSString *)input {
    equipDescription = input;
}
- (void) setCraneMfg: (NSString *)input{
    craneMfg = input;
}
- (void) setHoistMfg: (NSString *)input {
    hoistMfg = input;
}
- (void) setHoistMdl: (NSString *) input{
    hoistMdl = input;
}
- (void) dealloc {
    [self setName:nil];
    [self setContact:nil];
    [self setAddress:nil];
    [self setDate:nil];
    [self setJobNumber:nil];
    [self setEquipDescription:nil];
    [self setCraneMfg:nil];
    [self setHoistMfg:nil];
    [self setHoistMdl:nil];
}
@end
