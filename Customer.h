//
//  Customer.h
//  Inspection Form App
//
//  Created by adeiji on 4/7/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InspectedCrane;

@interface Customer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) InspectedCrane *inspectedCrane;

@end
