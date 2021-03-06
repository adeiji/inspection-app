//
//  Inspection.h
//  Inspection Form App
//
//  Created by Ade on 10/14/13.
//
//

#import <Foundation/Foundation.h>
#import "Customer.h"
#import "ItemListConditionStorage.h"
#import "InspectedCrane.h"

@class ItemListConditionStorage;

@interface Inspection : NSObject

@property (strong, nonatomic) InspectedCrane* inspectedCrane;
@property (strong, nonatomic) Customer* customer;
@property (strong, nonatomic) ItemListConditionStorage* itemList;
@property (strong, nonatomic) NSString *jobNumber;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *technicianName;

@property (strong, nonatomic) NSString *loadRatings;
@property (strong, nonatomic) NSString *testLoad;
@property (strong, nonatomic) NSString *remarksLimitations;
@property (strong, nonatomic) NSString *proofLoad;

@end
