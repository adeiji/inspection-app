//
//  Option.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Option : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;

@end
