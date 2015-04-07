//
//  InspectedCrane.h
//  Inspection Form App
//
//  Created by adeiji on 4/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Customer;

@interface InspectedCrane : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * equipmentNumber;
@property (nonatomic, retain) NSString * mfg;
@property (nonatomic, retain) NSString * hoistMfg;
@property (nonatomic, retain) NSString * craneSrl;
@property (nonatomic, retain) NSString * capacity;
@property (nonatomic, retain) NSString * hoistMdl;
@property (nonatomic, retain) NSString * hoistSrl;
@property (nonatomic, retain) NSString * craneDescription;
@property (nonatomic, retain) Customer *customer;

@end
