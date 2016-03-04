//
//  InspectionManager.m
//  Inspection Form App
//
//  Created by Ade on 11/15/13.
//
//

#import "InspectionManager.h"


@implementation InspectionManager

@synthesize crane;
@synthesize customer;
@synthesize inspection;

+ (InspectionManager *) sharedManager {
    static InspectionManager *sharedMyManager = nil;
    //This object will make sure that the method that we run is only run once
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
    }
    return self;
}

- (void) setCrane:(InspectedCrane *) myCrane {
    crane = myCrane;
}

- (void) setCustomer:(Customer *) myCustomer
{
    customer = myCustomer;
}

- (void) setInspection:(Inspection *) myInspection
{
    inspection = myInspection;
}

@end
