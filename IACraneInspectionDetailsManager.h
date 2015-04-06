//
//  IACraneInspectionDetailsManager.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <Foundation/Foundation.h>
#import "InspectionCrane.h"
#import "AppDelegate.h"
#import "InspectionOption.h"
#import "InspectionPoint.h"
#import <Parse/Parse.h>

@interface IACraneInspectionDetailsManager : NSObject

@property (strong, nonatomic) NSArray *cranes;
@property (strong, nonatomic) InspectionCrane *crane;
@property (strong, nonatomic) NSMutableArray *parts;
@property (strong, nonatomic) NSManagedObjectContext *context;

+ (id) sharedManager;
/*
 
 Get all the inspection details from the Database
 
 */
- (NSArray *) getInspectionDetails;
/*
 
 Store all the cranes, and their inspection details to the database
 
 */
- (void) saveInspectionDetailsWithCranes : (NSArray *) cranes;
/*
 
 Get all the inspection details from the server and store it in an array to be used through the application
 
 */
- (void) loadAllInspectionDetails;
@end
