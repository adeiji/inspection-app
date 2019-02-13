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

- (void) transferParseToFirebase {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFQuery *query = [PFQuery queryWithClassName:@"Crane"];
        NSArray *cranes = [query findObjects];
        IAFirebaseCraneInspectionDetailsManager *manager = [IAFirebaseCraneInspectionDetailsManager new];
        //Saves the cranes and the inspection details of the crane
        [manager saveCranesWithCranes:cranes];
    });
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

/*
 
 Get all the inspection details from the Database
 
 */
- (NSArray *) getInspectionDetails {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: kCoreDataClassCrane inManagedObjectContext:_context];
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

- (void) incrementIndicatorViewProgress : (UIProgressView *) progressIndicatorView
                      IncrementOfChange : (double) changeIncrement
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressIndicatorView.progress += changeIncrement;
    });
}

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

@end
