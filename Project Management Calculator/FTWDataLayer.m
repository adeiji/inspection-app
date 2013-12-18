//
//  FTWDataLayer.m
//  Profit Management Calculator
//
//  Created by Ade on 9/3/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "FTWDataLayer.h"
@implementation FTWDataLayer

- (NSObject*) init : (NSManagedObjectContext *) managedObjectContext
{
    self.managedObjectContext = managedObjectContext;
    
    return self;
}

- (void) SaveContext : (NSString *) calculationString
                date : (NSDate *) date
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *calculation;
    calculation = [NSEntityDescription insertNewObjectForEntityForName:@"Calculations" inManagedObjectContext:context];
    
    calculationString = [NSString stringWithFormat:@"%@", calculationString];
    
    //Save the tag in the database
    [calculation setValue:calculationString forKey:@"calculation"];
    [calculation setValue:date forKey:@"date"];
    
    NSError *error;
    
    if (![context save:&error])
    {
        NSLog([NSString stringWithFormat:@"%@", error]);
    }
    NSLog(@"Information Saved");
    
}


@end
