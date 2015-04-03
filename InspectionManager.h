//
//  InspectionManager.h
//  Inspection Form App
//
//  Created by Ade on 11/15/13.
//
//

#import <Foundation/Foundation.h>
#import "Crane.h"
#import "Customer.h"
#import "Inspection.h"
#import <Dropbox/Dropbox.h>

@interface InspectionManager : NSObject
{
    Crane *crane;
    Customer *customer;
    Inspection *inspection;
    DBAccount *dropboxAccount;
    DBDatastore *dataStore;
    DBTable *table;
}

@property (nonatomic, retain) Crane *crane;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) Inspection *inspection;
@property (nonatomic, retain) DBAccount *dropboxAccount;
@property (nonatomic, retain) DBDatastore *dataStore;
@property (nonatomic, retain) DBTable *table;


+ (InspectionManager *) sharedManager;

- (void) setCrane:(Crane *)myCrane;
- (void) setCustomer:(Customer *)myCustomer;
- (void) setInspection:(Inspection *)myInspection;
- (void) setDropboxAccount:(DBAccount *)myDropboxAccount;
- (void) setDataStore:(DBDatastore *)myDataStore;
- (void) setTable:(DBTable *) myTable;

@end
