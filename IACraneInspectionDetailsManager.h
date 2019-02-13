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
#import "Prompt.h"
#import "CoreDataCondition.h"
#import "PFInspectionDetails.h"
#import "PFCrane.h"

@interface IACraneInspectionDetailsManager : NSObject

@property (strong, nonatomic) NSArray *cranes;
@property (strong, nonatomic) InspectionCrane *crane;
@property (strong, nonatomic) NSMutableArray *parts;
@property (strong, nonatomic) NSManagedObjectContext *context;

+ (IACraneInspectionDetailsManager *) sharedManager;
/*
 
 Get all the inspection details from the Database
 
 */
- (NSArray *) getInspectionDetails;

- (InspectedCrane *) getCraneFromDatabaseWithHoistSrl : (NSString *) hoistSrl WithContextOrNil : (NSManagedObjectContext *) context;

/**
 Get all the data from parse and save in into Firebase

 @param cranes The cranes we get from Parse
 */
- (void) transferParseToFirebase;

/*
 
 Reset the inspection details crane by deleting all the objects inside of it
 
 */
- (void) resetInspectionDetailsDatabase;


/*
 
 Get all the inspection details from the server and store it in an array to be used through the application
 
 */
- (void) loadAllInspectionDetails;

//Create a crane object and send it to the recipient
- (InspectedCrane *) createCrane : (NSString*) hoistSrl
                       CraneType : (NSString*) craneType
                 EquipmentNumber : (NSString*) equipmentNumber
                        CraneMfg : (NSString*) craneMfg
                        hoistMfg : (NSString*) hoistMfg
                        CraneSrl : (NSString*) craneSrl
                        Capacity : (NSString*) capacity
                        HoistMdl : (NSString*) hoistMdl;

/*
 
 Get all the cranes that have already been inspected
 
 */
- (NSArray *) getAllInspectedCranes;

/*
 
 Get the specified crane from the InspectionCrane class
 
 */
- (NSArray *) getInspectionCraneOfType : (NSString *) craneType;

- (UIView *) showDownloadProgressBar;
- (NSArray *) getPromptsFromInspectionPoint : (InspectionPoint *) point;

/*
 
 Get all the condtions specific to the hoist srl
 
 */
- (NSArray *) getAllConditionsForCrane : (InspectedCrane *) crane WithContextOrNil : (NSManagedObjectContext *) context;

/*
 
 All the conditions that already exist for the crane on this device are deleted
 
 */
- (void) removeAllConditionsForCrane : (InspectedCrane *) crane
           UsingManagedObjectContext : (NSManagedObjectContext *) context;

/*
 
 Remove crane from the device
 
 */
- (void) deleteCraneFromDevice : (InspectedCrane *) crane;

/*
 
 If context is set to nil than we use the default global context from App Delegate
 
 */
- (void) saveAllConditionsForCrane : (InspectedCrane *) crane
                        Conditions : (NSArray *) conditions
    UsingManagedObjectContextOrNil : (NSManagedObjectContext *) context;

- (NSMutableArray *) getAllCranesWithInspections;

/*
 
 Return a new inspected Crane Object
 
 */
- (InspectedCrane *) getNewInspectedCraneObjectWithHoistSrl : (NSString *) hoistSrl
                                           WithContextOrNil : (NSManagedObjectContext *) context;

/*
 
 Return a new customer object

 */
- (Customer *) getNewCustomerObjectWithContext : (NSManagedObjectContext *) context;

- (void) saveContext : (NSManagedObjectContext *) myContext ;

- (NSArray *) getAllConditionsFromServerForCrane : (PFObject *) crane;

@end
