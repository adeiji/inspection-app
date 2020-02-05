//
//  InspectedCrane.h
//  Inspection Form App
//
//  Created by adeiji on 4/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CoreDataCondition, Customer;

@interface InspectedCrane : NSManagedObject

@property (nonatomic, retain) NSString * capacity;
@property (nonatomic, retain) NSString * craneDescription;
@property (nonatomic, retain) NSString * craneSrl;
@property (nonatomic, retain) NSString * equipmentNumber;
@property (nonatomic, retain) NSString * hoistMdl;
@property (nonatomic, retain) NSString * hoistMfg;
@property (nonatomic, retain) NSString * hoistSrl;
@property (nonatomic, retain) NSString * mfg;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Customer *customer;
@property (nonatomic, retain) NSOrderedSet *conditions;
@property (nonatomic, retain) NSNumber *shared;

@end

