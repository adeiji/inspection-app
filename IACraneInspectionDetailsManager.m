//
//  IACraneInspectionDetailsManager.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "IACraneInspectionDetailsManager.h"

NSString *const SHARED_INSPECTIONS_TABLE = @"SharedInspections";
NSString *const HOIST_SRL = @"hoistSrl";
NSString *const TO_USER = @"toUser";

@implementation IACraneInspectionDetailsManager

+ (id)sharedManager {
    static IACraneInspectionDetailsManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id) init {
    if (self = [super init])
    {
        _cranes = [NSMutableArray new];
        _context = ((AppDelegate *) [[UIApplication sharedApplication] delegate]).managedObjectContext;
    }
    
    return self;
}

- (UIView *) showDownloadProgressBar {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, 25)];
    [view setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:.8f]];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, view.frame.size.height / 2.0f, view.frame.size.width - 40, 10)];
    [progressView setProgress:0.0f];
    
    [view addSubview:progressView];
    [[view layer] setZPosition:1.0f];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
    
    return view;
}

/*
 
 Store all the cranes, and their inspection details to the database
 
 */
- (void) saveInspectionDetailsWithCranes : (NSArray *) cranes {
    UIView *progressContainerView = [self showDownloadProgressBar];
    UIProgressView *progressIndicatorView;
    for (UIView *subview in [progressContainerView subviews]) {
        if ([subview isKindOfClass:[UIProgressView class]])
        {
            progressIndicatorView = (UIProgressView *) subview;
        }
    }
    
    [self resetInspectionDetailsDatabase];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSManagedObjectContext *context =  ((AppDelegate *)[ [UIApplication sharedApplication] delegate]).managedObjectContext;
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setPersistentStoreCoordinator:(((AppDelegate *)[ [UIApplication sharedApplication] delegate]).managedObjectContext).persistentStoreCoordinator];
        NSMutableArray *cranesArray = [NSMutableArray new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:context];
        NSError *error;
        /* Get every crane that we just received from the server and grab all it's subdocuments and store them into coredata */
        for (id crane in cranes) {
            InspectionCrane *craneObject = [[InspectionCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
            craneObject.name = [crane objectForKey:kObjectName];
            // Convert the Parse Crane Object into a Core Data Object
            NSSet *set = [[NSSet alloc] init];
            [set setByAddingObjectsFromArray:[crane objectForKey:kInspectionPoints]];
            NSMutableArray *inspectionPoints = [NSMutableArray new];
            
            for (id inspectionPoint in crane[kInspectionPoints]) {
                PFObject *inspectionPointParseObject = (PFObject *) inspectionPoint;
                [inspectionPointParseObject fetch:&error];
                // Create Core Data objects for all the inspcetion points
                NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectionPoint inManagedObjectContext:context];
                InspectionPoint *inspectionPointObject = [[InspectionPoint alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                inspectionPointObject.name = [inspectionPointParseObject objectForKey:kObjectName];
                [set setByAddingObjectsFromArray:[inspectionPointParseObject objectForKey:kOptions]];
                inspectionPointObject.inspectionOptions = [NSOrderedSet orderedSetWithSet:set];
                [inspectionPoints addObject:inspectionPointObject];
                
                NSMutableArray *options = [NSMutableArray new];
                
                for (id option in inspectionPoint[kOptions]) {
                    PFObject *optionParseObject = (PFObject *) option;
                    [optionParseObject fetchIfNeeded];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectionOption inManagedObjectContext:context];
                    InspectionOption *inspectionOptionObject = [[InspectionOption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                    inspectionOptionObject.name = [optionParseObject objectForKey:kObjectName];
                    [options addObject:inspectionOptionObject];
                    [inspectionOptionObject setInspectionPoint:inspectionPointObject];
                }
                
                NSMutableArray *prompts = [NSMutableArray new];
                
                for (id promptObject in inspectionPoint[kPrompts])
                {
                    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassPrompt inManagedObjectContext:context];
                    Prompt *prompt = [[Prompt alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                    prompt.title = promptObject[kObjectName];
                    prompt.inspectionPoint = inspectionPointObject;
                    
                    if (promptObject[kRequiresDeficiency])
                    {
                        prompt.requiresDeficiency = [NSNumber numberWithBool:YES];
                    }
                    else {
                        prompt.requiresDeficiency = [NSNumber numberWithBool:NO];
                    }
                    
                    [prompts addObject:prompt];
                }
                
                if ([prompts count] > 0)
                {
                    [inspectionPointObject setPrompts:[NSOrderedSet orderedSetWithArray:prompts]];
                }
                
                [inspectionPointObject setInspectionOptions:[NSOrderedSet orderedSetWithArray:options]];
                [inspectionPointObject setInspectionCrane:craneObject];
                double progressToChange = (1.0f/cranes.count);
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressIndicatorView.progress += progressToChange / [crane[kInspectionPoints] count];
                });
            }
            [craneObject setInspectionPoints:[NSOrderedSet orderedSetWithArray:inspectionPoints]];
            [cranesArray addObject:craneObject];

        }

        [self saveAllWaterDistrictCranesWithContext : context];
        
        if ([context save:&error])
        {
            NSLog(@"com.inspectionapp.coredata - Error saving water district cranes");
        }
        
        [self loadAllInspectionDetails];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING object:nil];
        NSLog(@"%@ sent", NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING);
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressContainerView removeFromSuperview];
        });
    });
}

- (InspectedCrane *) getNewInspectedCraneObject {
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:_context];
    InspectedCrane *inspectedCrane = [[InspectedCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:_context];
    
    return inspectedCrane;
}

- (Customer *) getNewCustomerObject {
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCustomer inManagedObjectContext:_context];
    Customer *customer = [[Customer alloc] initWithEntity:entity insertIntoManagedObjectContext:_context];
    
    return customer;
}


- (void) saveAllWaterDistrictCranesWithContext : (NSManagedObjectContext *) context {
    [self deleteAllWaterDistrictCranesWithContext : context];
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"lvwwdcranes" ofType:@"plist"];
    NSArray *lvwwdCranes = [[NSArray alloc] initWithContentsOfFile:plistFilePath];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:context];
    
    NSEntityDescription *customerEntity = [NSEntityDescription entityForName:kCoreDataClassCustomer inManagedObjectContext:context];
    
    for (id dictionary in lvwwdCranes) {
        
        Customer *customer = [[Customer alloc] initWithEntity:customerEntity insertIntoManagedObjectContext:context];
        customer.name = @"LVVWD";
        customer.contact = @"ANDY ANDERSON";
        customer.email = @"ANDY.ANDERSON@LVVWD.COM";
        
        InspectedCrane *inspectedCrane = [[InspectedCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        inspectedCrane.type = dictionary[@"TYPE"];
        inspectedCrane.capacity = dictionary[@"CAPACITY"];
        inspectedCrane.hoistMdl = dictionary[@"MDL:HOIST"];
        inspectedCrane.mfg = dictionary[@"SRL: CRANE/MFG"];
        inspectedCrane.hoistSrl = dictionary[@"SRL: HOIST"];
        inspectedCrane.customer = customer;
    }
    
    NSError *error;
    if ([context save:&error])
    {
        NSLog(@"com.inspectionapp.coredata - Error saving water district cranes: \n%@", [error description]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WATER_DISTRICT_CRANES_SAVED object:nil];

}

- (void) deleteAllWaterDistrictCranesWithContext : (NSManagedObjectContext *) context {
    NSString *plistFilePath = [[NSBundle mainBundle] pathForResource:@"lvwwdcranes" ofType:@"plist"];
    NSArray *lvwwdCranes = [[NSArray alloc] initWithContentsOfFile:plistFilePath];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    for (id dictionary in lvwwdCranes) {
        NSString *hoistSrlToDelete = dictionary[@"SRL: HOIST"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", hoistSrlToDelete];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (id object in fetchedObjects) {
            [context deleteObject:object];
        }
    }
    
    [self deleteAllWaterDistrictCustomersWithContext:context];
    
    NSError *error;
    if ([context save:&error])
    {
        NSLog(@"com.inspectionapp.coredata - Error saving water district cranes: \n%@", [error description]);
    }

}

- (void) deleteAllWaterDistrictCustomersWithContext : (NSManagedObjectContext *) context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCustomer inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"LVWWD"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        for (id object in fetchedObjects) {
            [context deleteObject:object];
        }
    }
}
/*
 
 Get all the inspection details from the Database
 
 */
- (NSArray *) getInspectionDetails {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Make sure that all subdocuments are also retrieved from this fetch request
    [fetchRequest setReturnsObjectsAsFaults:NO];
    // Specify how the fetched objects should be sorted
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;
    
}

/*
 
 Reset the inspection details crane by deleting all the objects inside of it
 
 */
- (void) resetInspectionDetailsDatabase {
    NSArray *cranesFromDb = [self getInspectionDetails];
    
    for (InspectionCrane *crane in cranesFromDb) {
        for (InspectionPoint *inspectionPoint in crane.inspectionPoints) {
            for (InspectionOption *inspectionOption in inspectionPoint.inspectionOptions) {
                [_context deleteObject:inspectionOption];
            }
            [_context deleteObject:inspectionPoint];
        }
        [_context deleteObject:crane];
    }
    
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
}

/*
 
 Store the cranes in the array
 
 */
- (void) loadAllInspectionDetails {
    _cranes = [self getInspectionDetails];
}

//Create a crane object and send it to the recipient
- (InspectedCrane *) createCrane : (NSString*) hoistSrl
                       CraneType : (NSString*) craneType
                 EquipmentNumber : (NSString*) equipmentNumber
                        CraneMfg : (NSString*) craneMfg
                        hoistMfg : (NSString*) hoistMfg
                        CraneSrl : (NSString*) craneSrl
                        Capacity : (NSString*) capacity
                        HoistMdl : (NSString*) hoistMdl
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:_context];

    // If this crane already exist than we want to use the previous existing one and not add another to the DB
    InspectedCrane *crane = [self getCraneFromDatabaseWithHoistSrl:hoistSrl];
    
    if (!crane)
    {
        crane = [[InspectedCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:_context];
    }
    
    crane.hoistSrl          = hoistSrl;
    crane.type              = craneType;
    crane.equipmentNumber   = equipmentNumber;
    crane.mfg               = craneMfg;
    crane.hoistMfg          = hoistMfg;
    crane.craneSrl          = craneSrl;
    crane.capacity          = capacity;
    crane.hoistMdl          = hoistMdl;
    
    NSLog(@"Crane object created - com.inspectionapp.coredata");
    
    return crane;
}

- (InspectedCrane *) getCraneFromDatabaseWithHoistSrl : (NSString *) hoistSrl {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", hoistSrl];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    if ([fetchedObjects count] == 0) {
        return nil;
    }
    
    return fetchedObjects[0];
}

/*
 
 Get all the cranes that have already been inspected
 
 */
- (NSArray *) getAllInspectedCranes {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kCoreDataClassAttributeHoistSrl
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

/*
 
 Get the specified crane from the InspectionCrane class
 
 */
- (NSArray *) getInspectionCraneOfType : (NSString *) craneType {
    
    NSManagedObjectContext *context = [((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == [c] %@", craneType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;
}

- (NSArray *) getPromptsFromInspectionPoint:(InspectionPoint *)point {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassPrompt inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inspectionPoint == %@", point];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {

    }
    
    return fetchedObjects;
}

- (void) removeAllConditionsForCrane : (InspectedCrane *) crane {
    
    NSArray *conditions = [self getAllConditionsForCrane:crane];
    for (CoreDataCondition *condition in conditions) {
        [_context deleteObject:condition];
    }
    
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
}

- (void) saveAllConditionsForCrane : (InspectedCrane *) crane
                        Conditions : (NSArray *) conditions;
{
    [self removeAllConditionsForCrane:crane];
    NSManagedObjectContext *context = [((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:context];

    for (Condition *condition in conditions) {
        CoreDataCondition *coreDataCondition = [[CoreDataCondition alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        coreDataCondition.isDeficient = [NSNumber numberWithBool:condition.deficient];
        coreDataCondition.isApplicable = [NSNumber numberWithBool:condition.applicable];
        coreDataCondition.notes = condition.notes;
        coreDataCondition.optionSelectedIndex = [NSNumber numberWithInteger:condition.pickerSelection];
        coreDataCondition.optionSelected = condition.deficientPart;
        coreDataCondition.optionLocation = [NSNumber numberWithInteger:condition.optionLocation];
        coreDataCondition.hoistSrl = crane.hoistSrl;
    }
    
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
}

- (NSMutableArray *) getAllCranesWithInspections {
    
    NSArray *cranes = [self getAllInspectedCranes];
    NSMutableArray *inspectedCranes = [NSMutableArray new];
    
    for (InspectedCrane *crane in cranes) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        // Specify criteria for filtering which objects to fetch
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", crane.hoistSrl];
        [fetchRequest setPredicate:predicate];
        NSError *error;
        NSUInteger count = [_context countForFetchRequest:fetchRequest error:&error];
        
        if (count > 0) {
            [inspectedCranes addObject:crane];
        }
    }
    
    return inspectedCranes;
}

- (NSArray *) getAllConditionsForCrane : (InspectedCrane *) crane {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", crane.hoistSrl];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;

}

/*
 
 Delete previous occurences of this inspection that were already sent to this user
 
 */
- (void) deleteEarlierInspectionOfCraneFromServer : (InspectedCrane *) crane
                                          ForUser : (PFUser *) user
{
    PFQuery *query = [PFInspectionDetails query];
    [query whereKey:HOIST_SRL equalTo:crane.hoistSrl];
    [query whereKey:TO_USER equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if ([objects count] > 0) {
            for (PFInspectionDetails *object in objects) {
                [object deleteInBackground];
            }
        }
    }];
    
    query = [PFCrane query];
    [query whereKey:HOIST_SRL equalTo:crane.hoistSrl];
    [query whereKey:TO_USER equalTo:user];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if ([objects count] > 0) {
            for (PFInspectionDetails *object in objects) {
                [object deleteInBackground];
            }
        }
    }];
}

/*
 
 Get all the cranes for the current user from the server
 
 */
- (NSArray *) getAllCranesForCurrentUserFromServer {
    PFQuery *query = [PFCrane query];
    NSError *error;
    [query whereKey:@"toUser" equalTo:[PFUser currentUser]];
    NSArray *cranes = [query findObjects:&error];
    return cranes;
}

- (NSArray *) getAllConditionsFromServerForCrane : (PFCrane *) crane {
    PFQuery *query = [PFInspectionDetails query];
    [query whereKey:HOIST_SRL equalTo:crane.hoistSrl];
    [query whereKey:TO_USER equalTo:[PFUser currentUser]];
    
    NSError *error;
    NSArray * conditions = [query findObjects:&error];
    return conditions;
}

/*
 
 Push the inspection to the server
 
 */
- (void) shareCraneDetails : (InspectedCrane *) crane
                  WithUser : (PFUser *) user {
    NSArray *inspectionDetails = [[IACraneInspectionDetailsManager sharedManager] getAllConditionsForCrane:crane];
    NSMutableArray *pfInspectionDetailsObjects = [NSMutableArray new];
    
    [self deleteEarlierInspectionOfCraneFromServer:crane ForUser:user];
    [self saveCraneToServer:crane WithUser: user];
    
    for (CoreDataCondition *condition in inspectionDetails) {
        
        PFInspectionDetails *inspectionDetails = [PFInspectionDetails object];
        inspectionDetails.isDeficient = condition.isDeficient.boolValue;
        inspectionDetails.isApplicable = condition.isApplicable.boolValue;
        inspectionDetails.notes = condition.notes;
        inspectionDetails.optionSelectedIndex = condition.optionSelectedIndex.intValue;
        inspectionDetails.optionSelected = condition.optionSelected;
        inspectionDetails.hoistSrl = condition.hoistSrl;
        
        if ([PFUser currentUser] != nil) {
            inspectionDetails.toUser = user;
        }
        
        [pfInspectionDetailsObjects addObject:inspectionDetails];
    }
    
    [PFObject saveAllInBackground:pfInspectionDetailsObjects block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded && !error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Successful" message:@"Inspection Was Sent Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if (error) {
        }
    }];
}

- (void) saveCraneToServer  : (InspectedCrane *)crane
                   WithUser : (PFUser *) user {
    
    PFCrane *craneObject = [PFCrane object];
    craneObject.capacity = crane.capacity;
    craneObject.craneDescription = crane.craneDescription;
    craneObject.craneSrl = crane.craneSrl;
    craneObject.equipmentNumber = crane.equipmentNumber;
    craneObject.hoistMdl = crane.hoistMdl;
    craneObject.hoistSrl = crane.hoistSrl;
    craneObject.hoistMfg = crane.hoistMfg;
    craneObject.type = crane.type;
    craneObject.toUser = user;
    
    PFCustomer *customer = [PFCustomer object];
    customer.name = crane.customer.name;
    customer.contact = crane.customer.contact;
    customer.address = crane.customer.address;
    customer.email = crane.customer.email;
    
    craneObject.customer = customer;
    [craneObject saveInBackground];
}

- (void) saveContext {
    NSError *error;
    
    if ([_context save:&error] == NO) {
        NSLog(@"Error saving context %@", error.description);
    }
}

//Inserts a customer into the dropbox datastore jobs table
+ (void) InsertCustomerIntoTable : (Customer*) customer
{
    
}

- (Customer*) createCustomer : (NSString*) customerName
             CustomerContact : (NSString*) customerContact
             CustomerAddress : (NSString*) customerAddress
               CustomerEmail : (NSString*) customerEmail
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCustomer inManagedObjectContext:_context];
    Customer *customer = [[Customer alloc] initWithEntity:entity insertIntoManagedObjectContext:_context];
    customer.name       = customerName;
    customer.contact    = customerContact;
    customer.address    = customerAddress;
    customer.email      = customerEmail;
    
    return customer;
}


@end
