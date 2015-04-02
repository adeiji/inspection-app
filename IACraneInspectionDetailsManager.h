//
//  IACraneInspectionDetailsManager.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <Foundation/Foundation.h>
#import "InspectionCrane.h"

@interface IACraneInspectionDetailsManager : NSObject

@property (strong, nonatomic) NSArray *cranes;
@property (strong, nonatomic) InspectionCrane *crane;
@property (strong, nonatomic) NSMutableArray *parts;

+ (id) sharedManager;

@end
