//
//  IACraneInspectionDetailsManager.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "IACraneInspectionDetailsManager.h"

@implementation IACraneInspectionDetailsManager

+ (id)sharedManager {
    static IACraneInspectionDetailsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

@end
