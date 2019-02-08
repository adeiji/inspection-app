//
//  IACraneInspectionDetailsManager.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "IACraneInspectionDetailsManager.h"
#import "Inspection_Form_App-Swift.h"

NSString *const SHARED_INSPECTIONS_TABLE = @"SharedInspections";
NSString *const HOIST_SRL = @"hoistSrl";
NSString *const TO_USER = @"toUser";

@implementation IACraneInspectionDetailsManager

+ (IACraneInspectionDetailsManager *)sharedManager {
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

- (void) transferParseToFirebase : (NSArray *) cranes {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IAFirebaseCraneInspectionDetailsManager *manager = [IAFirebaseCraneInspectionDetailsManager new];
        //Saves the cranes and the inspection details of the crane
        [manager saveCranesWithCranes:cranes];
        // Saves all the inspected cranes to firebase that are stored in the Parse DB
        [self saveAllInspectedCranesToFirebase];
    });
}

/*
 
 Store all the cranes, and their inspection details to the database
 
 */
// Saving Done
// Still need to do getting
- (void) saveInspectionDetailsWithCranes : (NSArray *) cranes {
    IAFirebaseCraneInspectionDetailsManager *manager = [IAFirebaseCraneInspectionDetailsManager new];
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
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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
                    
                    
                    if ([promptObject isKindOfClass:[NSString class]]) {
                        prompt.title = promptObject;
                    }
                    else {
                        prompt.title = promptObject[kObjectName];
                        if (promptObject[kRequiresDeficiency])
                        {
                            prompt.requiresDeficiency = [NSNumber numberWithBool:YES];
                        }
                        else {
                            prompt.requiresDeficiency = [NSNumber numberWithBool:NO];
                        }
                    }
                    prompt.inspectionPoint = inspectionPointObject;
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
        
        if ([context save:&error])
        {
            NSLog(@"com.inspectionapp.coredata - Error saving crane details from Parse - %@", error);
        }
        
        [self getAllCurrentUsersInspectionsFromServerUsingManagedObjectContext:context];
        [self loadAllInspectionDetails];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING object:nil];
        NSLog(@"%@ sent", NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING);
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressContainerView removeFromSuperview];
        });
    });
}

// Done
- (NSArray *) getAllInspectionDetailsFromServerForCurrentUserWithHoistSrl : (NSString *) hoistSrl {
    // Get all inspection details from server
    PFQuery *query = [PFInspectionDetails query];
    NSError *error;
    [query whereKeyDoesNotExist:kParseToUser];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    [query whereKey:kParseHoistSrl equalTo:hoistSrl];
    NSMutableArray *allInspectionDetails = [NSMutableArray new];
    int counter=0;
    [query setLimit:1000];
    
    while ([allInspectionDetails count] < [query countObjects]) {
        counter++;
        NSArray *inspectionDetails = [query findObjects:&error];
        if (error) {
            NSLog(@"Error getting inspection details from server - %@", error.description);
        }
        else {
            [allInspectionDetails addObjectsFromArray:inspectionDetails];
        }
        [query setSkip:1000 * counter];
    }
    return allInspectionDetails;
}

// Done
- (NSArray *) getAllCranesFromServerForCurrentUser {
    // Get all the cranes that are from the current user's device
    PFQuery *query = [PFCrane query];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    [query whereKeyDoesNotExist:kParseToUser];
    [query setLimit:1000];
    NSMutableArray *allCranes = [NSMutableArray new];
    int counter = 0;
    
    while ([allCranes count] < [query countObjects]) {
        NSError *error;
        NSArray *cranes = [query findObjects:&error];
        [allCranes addObjectsFromArray:cranes];
        
        if (error) {
            NSLog(@"Error getting cranes from server - %@", error.description);
        }
        
        counter ++;
        [query setSkip:counter * 1000];
    }
    
    return allCranes;
}

- (void) getAllCurrentUsersInspectionsFromServerUsingManagedObjectContext : (NSManagedObjectContext *) context {
    NSArray *inspectedCranes = [self getAllCranesFromServerForCurrentUser];
    
    for (PFCrane *retrievedInspectedCrane in inspectedCranes) {
        [retrievedInspectedCrane getCoreDataObjectWithContextOrNil:context];
        InspectedCrane *inspectedCrane = [self getCraneFromDatabaseWithHoistSrl:retrievedInspectedCrane.hoistSrl WithContextOrNil:context];
        NSArray *inspectionDetails = [self getAllInspectionDetailsFromServerForCurrentUserWithHoistSrl:retrievedInspectedCrane.hoistSrl];
        NSArray *inspectionDetailCoreDataObjects = [self convertParseConditionsToConditionObjects:inspectionDetails];
        [[IACraneInspectionDetailsManager sharedManager] saveAllConditionsForCrane:inspectedCrane Conditions:inspectionDetailCoreDataObjects UsingManagedObjectContextOrNil: context];
    }
}

- (InspectedCrane *) getNewInspectedCraneObjectWithHoistSrl : (NSString *) hoistSrl WithContextOrNil: (NSManagedObjectContext *) context {
    if (!context) {
        context = _context;
    }
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:context];
    InspectedCrane *inspectedCrane = [[InspectedCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    InspectedCrane *existingCrane = [self getCraneFromDatabaseWithHoistSrl:hoistSrl WithContextOrNil:context];
    
    if (existingCrane != nil) {
        [context deleteObject:existingCrane];
    }
    
    return inspectedCrane;
}

- (Customer *) getNewCustomerObjectWithContext : (NSManagedObjectContext *) context {
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCustomer inManagedObjectContext:context];
    Customer *customer = [[Customer alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    return customer;
}

- (void) saveAllWaterDistrictCranes {
    
    [self saveAllWaterDistrictCranesWithContext:_context];
    
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
        NSLog(@"com.inspectionapp.coredata - Error deleting water district cranes: \n%@", [error description]);
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
    InspectedCrane *crane = [self getCraneFromDatabaseWithHoistSrl:hoistSrl WithContextOrNil:nil];
    
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

- (InspectedCrane *) getCraneFromDatabaseWithHoistSrl : (NSString *) hoistSrl WithContextOrNil : (NSManagedObjectContext *) context {
    if (!context) {
        context = _context;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectedCrane inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", hoistSrl];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
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

- (void) removeAllConditionsForCrane : (InspectedCrane *) crane
           UsingManagedObjectContext : (NSManagedObjectContext *) context
{
    
    if (!context) {
        context = _context;
    }
    
    NSArray *conditions = [self getAllConditionsForCrane:crane WithContextOrNil:context];
    for (CoreDataCondition *condition in conditions) {
        [context deleteObject:condition];
    }
    
    [self saveContext:context];
}

- (void) saveAllConditionsForCrane : (InspectedCrane *) crane
                        Conditions : (NSArray *) conditions
    UsingManagedObjectContextOrNil : (NSManagedObjectContext *) context;
{
 
    if (!context) {
        context = [((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext];
    }
    [self removeAllConditionsForCrane:crane UsingManagedObjectContext:context];
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
    
    [self saveContext:context];
}


- (void) deleteCraneFromDevice : (InspectedCrane *) crane {
    InspectedCrane *craneObject = [self getCraneFromDatabaseWithHoistSrl:crane.hoistSrl WithContextOrNil:nil];
    
    if (craneObject != nil) {
        [_context deleteObject:craneObject];
    }
    
}

- (NSMutableArray *) getAllCranesWithInspections {
    
    NSArray *cranes = [self getAllInspectedCranes];
    NSMutableArray *inspectedCranes = [NSMutableArray new];
    BOOL duplicateCrane;
    
    for (InspectedCrane *crane in cranes) {
        duplicateCrane = NO;
        
        // Check the cranes that have been inspected and see if the current crane being inspected is a duplicate
        for (InspectedCrane *myInspectedCrane in inspectedCranes) {
            if (myInspectedCrane.hoistSrl == crane.hoistSrl) {
                break;
                duplicateCrane = YES;
            }
        }
        
        if (!duplicateCrane) { // If the crane is a duplicate than we don't need to do anything with it
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
    }
    
    return inspectedCranes;
}

- (NSArray *) getAllConditionsForCrane : (InspectedCrane *) crane WithContextOrNil : (NSManagedObjectContext *) context {
    
    if (!context) {
        context = _context;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hoistSrl == %@", crane.hoistSrl];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;

}

/*
 
 Delete previous occurences of this inspection that were already sent to this user
 
 */
// Done, it's now gecome updateInspectino in IAFirebaseCraneInspectionDetailsManager
- (void) deleteEarlierInspectionOfCraneFromServer : (InspectedCrane *) crane
                                          ForUser : (PFUser *) user                                          
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFQuery *query = [PFInspectionDetails query];
        [query whereKey:HOIST_SRL equalTo:crane.hoistSrl];
        [query whereKey:TO_USER equalTo:user];
        [query setLimit:1000];
        
        while ([query countObjects] > 0) {
            NSArray *inspectionDetails = [query findObjects];
            [PFObject deleteAll:inspectionDetails];
        }
    });
}

/*
 
 Get all the cranes for the current user from the server
 
 */
//DONE
- (NSArray *) getAllCranesForCurrentUserFromServer {
    NSMutableArray *allCranes = [NSMutableArray new];
    
    PFQuery *query = [PFCrane query];
    NSError *error;
    [query whereKey:kParseToUser equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    int counter=0;
    while ([allCranes count] < [query countObjects]) {
        NSArray *cranes = [query findObjects:&error];
        [allCranes addObjectsFromArray:cranes];
        if (error) {
            NSLog(@"Error retrieving cranes from server - com.inspectionapp.errorretrievingcranes - %@", error.description);
        }
        
        counter++;
        [query setSkip:1000 * counter];
    }
    return allCranes;
}
// DONE
- (NSArray *) getAllConditionsFromServerForCrane : (PFObject *) crane {
    NSMutableArray *allConditions = [NSMutableArray new];
    PFQuery *query = [PFInspectionDetails query];
    
    [query whereKey:HOIST_SRL equalTo: ((PFCrane *) crane).hoistSrl];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    [query setLimit:1000];
    int counter = 0;
    
    while ([allConditions count] < [query countObjects]) {
        counter++;
        NSError *error;
        NSArray * conditions = [query findObjects:&error];
        [allConditions addObjectsFromArray:conditions];
        
        if (error) {
            NSLog(@"Error retrieving cranes from server - com.inspectionapp.errorretrievingconditions - %@", error.description);
        }
        [query setSkip:1000*counter];
    }
    
    return allConditions;
}

- (void) saveAllInspectedCranesToFirebase {
    
    PFQuery *query = [PFCrane query];
    [query setLimit:1000];
    
    int counter = 0;
    while ([query countObjects] > 0) {
        NSArray *cranes = [query findObjects];
        [[IAFirebaseCraneInspectionDetailsManager new] saveInspectedCranesFromParseCraneObjectWithCranes:cranes];
        counter = counter + 1;
        [query setSkip:1000 * counter];
    }
}

- (void) deleteCustomersFromServerWithFromCurrentUser {
    PFQuery *query = [PFCustomer query];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    [query whereKeyDoesNotExist:kParseToUser];
    [query setLimit:1000];
    
    while ([query countObjects] > 0) {
        NSArray *customers = [query findObjects];
        NSError *error;
        [PFObject deleteAll:customers error:&error];
        if (error) {
            NSLog(@"Error on deleting all cranes - %@", error.description);
        }
    }
}

- (void) deleteCranesFromServerWithFromCurrentUser {
    
    PFQuery *query = [PFCrane query];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    [query whereKeyDoesNotExist:kParseToUser];
    [query setLimit:1000];
    
    while ([query countObjects] > 0) {
        NSArray *objects = [query findObjects];
        NSError *error;
        
        [PFObject deleteAll:objects error:&error];
        if (error) {
            NSLog(@"Error on deleting all cranes - %@", error.description);
        }
    }
}


/*
 
 Push the inspection to the server
 
 */
- (void) shareCraneDetails : (InspectedCrane *) crane
                  WithUser : (PFUser *) user
    WithViewControllerOrNilToDisplayAlert : (UIViewController *) viewController
{
        
    NSArray *inspectionDetails = [[IACraneInspectionDetailsManager sharedManager] getAllConditionsForCrane:crane WithContextOrNil:nil];
    NSMutableArray *pfInspectionDetailsObjects = [NSMutableArray new];
    
    [self deleteEarlierInspectionOfCraneFromServer:crane ForUser:user];
    [self saveCraneToServer:crane WithToUser: user WithFromUser:[PFUser currentUser]];
    
    NSString *userId = [UtilityFunctions getUserId];
    IAFirebaseCraneInspectionDetailsManager *manager = [IAFirebaseCraneInspectionDetailsManager new];
    [manager saveInspectionWithHoistSrl:crane.hoistSrl inspectionDetails:inspectionDetails userId:userId];
    
    for (CoreDataCondition *condition in inspectionDetails) {
        
        PFInspectionDetails *inspectionDetail = [PFInspectionDetails object];
        inspectionDetail.isDeficient = [condition.isDeficient boolValue];
        inspectionDetail.isApplicable = [condition.isApplicable boolValue];
        inspectionDetail.notes = condition.notes;
        inspectionDetail.optionSelectedIndex = [condition.optionSelectedIndex intValue];
        inspectionDetail.optionSelected = condition.optionSelected;
        inspectionDetail.hoistSrl = condition.hoistSrl;
        inspectionDetail.optionLocation = [condition.optionLocation intValue];
        
        if ([PFUser currentUser] != nil) {
            inspectionDetail.toUser = user;
        }
        
        [pfInspectionDetailsObjects addObject:inspectionDetail];
    }
    
    [PFObject saveAllInBackground:pfInspectionDetailsObjects block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded && !error) {
            
            if (viewController) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Inspection Sent Successfully" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [viewController presentViewController:alert animated:YES completion:nil];
            }
        }
        else if (error) {
            NSLog(@"%@", error.description);
        }
    }];
}

- (NSArray *) convertParseConditionsToConditionObjects : (NSArray *) objects {

    NSMutableArray *conditions = [NSMutableArray new];
    
    for (PFInspectionDetails *details in objects) {
        Condition *condition = [Condition new];
        condition.applicable = details.isApplicable;
        condition.deficient = details.isDeficient;
        condition.notes = details.notes;
        if (![details.notes isEqualToString:@""]) {
            
        }
        
        condition.optionLocation = details.optionLocation;
        condition.pickerSelection = details.optionSelectedIndex;
        condition.deficientPart = details.optionSelected;
        
        [conditions addObject:condition];
    }
    
    NSArray *sortedArray;
    sortedArray = [conditions sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger locationOfObj1 = ((Condition *) obj1).optionLocation;
        NSInteger locationOfObj2 = ((Condition *) obj2).optionLocation;
        
        return locationOfObj1 > locationOfObj2;
    }];
    
    
    return sortedArray;
}

// Done
- (void) saveCraneToServer  : (InspectedCrane *)crane
                 WithToUser : (PFUser *) user
               WithFromUser : (PFUser *) fromUser {
    
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
    craneObject.mfg = crane.mfg;
    craneObject.fromUser = fromUser;
    
    PFCustomer *customer = [PFCustomer object];
    customer.name = crane.customer.name;
    customer.contact = crane.customer.contact;
    customer.address = crane.customer.address;
    customer.email = crane.customer.email;
    customer.fromUser = fromUser;
    
    craneObject.customer = customer;
    
    NSError *error;
    if (![NSThread isMainThread]) {
        [craneObject save:&error];
    }
    else {
        [craneObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!succeeded || error) {
                NSLog(@"Method: SaveCraneToServer:WithToUser:WithFromUser - Error saving crane to server - %@", error.description);
            }
        }];
    }
}

- (void) saveContext : (NSManagedObjectContext *) myContext {
    NSError *error;
    
    // If a context is not set, than we use the default context for the object.  This is because at times we use a different context when saving to Core Data from a background thread
    if (!myContext) {
        if ([_context save:&error] == NO) {
            NSLog(@"Error saving context %@", error.description);
        }
    }
    else {
        if ([myContext save:&error] == NO) {
            NSLog(@"Error saving context %@", error.description);
        }
    }
}

/*
 
 We push all the cranes from this device along with their inspections onto the server
 
 */
- (void) backupCranesOnDevice {
    
    NSArray *cranes = [self getAllCranesWithInspections];
    NSMutableArray *pfInspectionDetailsObjects = [NSMutableArray new];
    
    UIView *progressContainerView = [self showDownloadProgressBar];
    UIProgressView *progressIndicatorView;
    for (UIView *subview in [progressContainerView subviews]) {
        if ([subview isKindOfClass:[UIProgressView class]])
        {
            progressIndicatorView = (UIProgressView *) subview;
        }
    }
    
    // Use dispatch_queue_create so that we get FIFO capabilities
    dispatch_queue_t parseBackgroundQueue = dispatch_queue_create("com.parsebackground.queue", NULL);
    
    dispatch_async(parseBackgroundQueue, ^{
        // Delete the cranes from the server but we want to complete the deletion before a save is performed so we use a background thread and than use the findObjects method which blocks the thread until completed
        progressIndicatorView.progress = .15;
        [self deleteCranesFromServerWithFromCurrentUser];
        progressIndicatorView.progress = .25;
        [self deleteInspectionDetailsFromServerWithFromCurrentUser];
        progressIndicatorView.progress = .35;
        [self deleteCustomersFromServerWithFromCurrentUser];
        progressIndicatorView.progress = .45;
    });
    
    for (InspectedCrane *crane in cranes) {
        NSArray *inspectionDetails = [self getAllConditionsForCrane:crane WithContextOrNil:nil];  // Grabs from local database
        for (CoreDataCondition *condition in inspectionDetails) {
            PFInspectionDetails *inspectionDetail = [PFInspectionDetails object];
            inspectionDetail.isDeficient = [condition.isDeficient boolValue];
            inspectionDetail.isApplicable = [condition.isApplicable boolValue];
            inspectionDetail.notes = condition.notes;
            inspectionDetail.optionSelectedIndex = [condition.optionSelectedIndex intValue];
            inspectionDetail.optionSelected = condition.optionSelected;
            inspectionDetail.hoistSrl = condition.hoistSrl;
            inspectionDetail.optionLocation = [condition.optionLocation intValue];
            inspectionDetail.fromUser = [PFUser currentUser];
            [pfInspectionDetailsObjects addObject:inspectionDetail];
        }
        progressIndicatorView.progress = .75;
        dispatch_async(parseBackgroundQueue, ^{
            // Delete the cranes from the server but we want to complete the deletion before a save is performed so we use a background thread and than use the findObjects method which blocks the thread until completed
            [self saveCraneToServer:crane WithToUser:nil WithFromUser:[PFUser currentUser]];
            progressIndicatorView.progress = .85;
        });
    }
    
    dispatch_async(parseBackgroundQueue, ^{
        [self saveAllPFObjectsInArray:pfInspectionDetailsObjects];
        progressIndicatorView.progress = 1.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressContainerView removeFromSuperview];
            
        });
    });
}

- (void) incrementIndicatorViewProgress : (UIProgressView *) progressIndicatorView
                      IncrementOfChange : (double) changeIncrement
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressIndicatorView.progress += changeIncrement;
    });
}

// Done - deleteAllDataFromCollection
- (void) deleteInspectionDetailsFromServerWithFromCurrentUser {
    // Get all the InspectionDetails from the current user
    PFQuery *query = [PFInspectionDetails query];
    [query setLimit:1000];
    [query whereKey:kParseFromUser equalTo:[PFUser currentUser]];
    
    while ([query countObjects] > 0) {
        NSArray *inspectionDetailsFromServer = [query findObjects];
        NSError *error;
        
        [PFObject deleteAll:inspectionDetailsFromServer error:&error];
        
        if (error) {
            NSLog(@"Error deleting inspection details from the server on backup - %@", error.description);
        }
    }
    
}

- (void) saveAllPFObjectsInArray : (NSArray *) pfObjects {
    NSError *error;
    [PFObject saveAll:pfObjects error:&error];
    
    if (error) {
        NSLog(@"%@", error.description);
    }
    else {
        // Display that the data was backed up successfully
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Data Backed Up Successfully" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
        });
    }
}

@end
