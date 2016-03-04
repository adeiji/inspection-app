//
//  InspectionManager.h
//  Inspection Form App
//
//  Created by Ade on 11/15/13.
//
//

#import <Foundation/Foundation.h>
#import "InspectionCrane.h"
#import "Customer.h"
#import "Inspection.h"

@interface InspectionManager : NSObject
{
    InspectedCrane *crane;
    Customer *customer;
    Inspection *inspection;
}

@property (nonatomic, retain) InspectedCrane *crane;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) Inspection *inspection;


+ (InspectionManager *) sharedManager;

- (void) setCrane:(InspectedCrane *)myCrane;
- (void) setCustomer:(Customer *)myCustomer;
- (void) setInspection:(Inspection *)myInspection;

@end
