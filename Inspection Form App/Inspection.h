//
//  Inspection.h
//  Inspection Form App
//
//  Created by Ade on 10/14/13.
//
//

#import <Foundation/Foundation.h>
#import "InspectionCrane.h"
#import "Customer.h"
#import "ItemListConditionStorage.h"

@interface Inspection : NSObject

@property (strong, nonatomic) InspectionCrane* crane;
@property (strong, nonatomic) Customer* customer;
@property (strong, nonatomic) ItemListConditionStorage* itemList;
@property (strong, nonatomic) NSString *jobNumber;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *technicianName;

@end
