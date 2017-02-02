//
//  PFCrane.h
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import <Parse/Parse.h>
#import "PFCustomer.h"
#import "InspectedCrane.h"
#import "Customer.h"
#import "IACraneInspectionDetailsManager.h"

@interface PFCrane : PFObject <PFSubclassing>

+ (NSString *) parseClassName;

@property (retain) NSString *capacity;
@property (retain) NSString *craneDescription;
@property (retain) NSString *craneSrl;
@property (retain) NSString *equipmentNumber;
@property (retain) NSString *hoistMdl;
@property (retain) NSString *hoistMfg;
@property (retain) NSString *hoistSrl;  //unique
@property (retain) NSString *mfg;
@property (retain) NSString *type;
@property (retain) PFCustomer *customer;
@property (retain) PFUser *toUser;
@property (retain) PFUser *fromUser;

/*
 
 Turns the PFObject into a Core Data object.  If the Context is set to nil, than we use the default global NSManagedObjectContext
 
 */
- (InspectedCrane *) getCoreDataObjectWithContextOrNil : (NSManagedObjectContext *) context;

@end

