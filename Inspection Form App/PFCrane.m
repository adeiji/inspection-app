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
@dynamic toUser;

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"InspectedCrane";
}

- (InspectedCrane *) getCoreDataObject {
    
    
    InspectedCrane *inspectedCrane = [[IACraneInspectionDetailsManager sharedManager] getNewInspectedCraneObjectWithHoistSrl:self.hoistSrl];
    
    inspectedCrane.capacity = self.capacity;
    inspectedCrane.craneDescription = self.craneDescription;
    inspectedCrane.craneSrl = self.craneSrl;
    inspectedCrane.equipmentNumber = self.equipmentNumber;
    inspectedCrane.hoistMdl = self.hoistMdl;
    inspectedCrane.hoistMfg = self.hoistMfg;
    inspectedCrane.hoistSrl = self.hoistSrl;
    inspectedCrane.mfg = self.mfg;
    inspectedCrane.type = self.type;
    
    Customer *customer = [[IACraneInspectionDetailsManager sharedManager] getNewCustomerObject];
    [self.customer fetchIfNeeded];
    customer.name = self.customer.name;
    customer.address = self.customer.address;
    customer.email = self.customer.email;
    customer.inspectedCrane = inspectedCrane;
    inspectedCrane.customer = customer;
    // Since we know that whenever we need to get an InspectedCrane Object from a PFCrane Object this inspection has been downloaded from the server, we set the shared property to true of the InspectedCrane Object
    inspectedCrane.shared = [NSNumber numberWithBool:true];
    [[IACraneInspectionDetailsManager sharedManager] saveContext];
    return inspectedCrane;
}

@end
