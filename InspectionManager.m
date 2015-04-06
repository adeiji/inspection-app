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
@synthesize dropboxAccount;
@synthesize dataStore;
@synthesize table;

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

- (void) setCrane:(InspectionCrane *) myCrane {
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

- (void) setDropboxAccount:(DBAccount *)myDropboxAccount
{
    dropboxAccount = myDropboxAccount;
}

- (void) setDataStore:(DBDatastore *)myDataStore
{
    dataStore = myDataStore;
}


- (void) setTable:(DBTable *) myTable
{
    table = myTable;
}

@end
