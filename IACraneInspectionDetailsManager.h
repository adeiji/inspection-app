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
- (NSArray *) getAllConditionsForCrane : (InspectedCrane *) crane;
- (void) saveAllConditionsForCrane : (InspectedCrane *) crane
                        Conditions : (NSArray *) conditions;

- (void) saveAllWaterDistrictCranes;
- (NSMutableArray *) getAllCranesWithInspections;
/*
 
 Push the details for the selected crane to the server
 
 */
- (void) shareCraneDetails : (InspectedCrane *) crane
                  WithUser : (PFUser *) user;


- (NSArray *) getAllCranesForCurrentUserFromServer;

- (void) saveCraneToServer : (InspectedCrane *) crane;

/*
 
 Return a new inspected Crane Object
 
 */
- (InspectedCrane *) getNewInspectedCraneObject;

/*
 
 Return a new customer object

 */
- (Customer *) getNewCustomerObject;

- (void) deleteEarlierInspectionOfCraneFromServer : (InspectedCrane *) crane
                                          ForUser : (PFUser *) user;

- (void) saveContext;

- (Customer*) createCustomer : (NSString*) customerName
             CustomerContact : (NSString*) customerContact
             CustomerAddress : (NSString*) customerAddress
               CustomerEmail : (NSString*) customerEmail;
@end
