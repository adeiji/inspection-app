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
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
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

        if ([context save:&error])
        {
            
        }
        [self loadAllInspectionDetails];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING object:nil];
        NSLog(@"%@ sent", NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING);
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressContainerView removeFromSuperview];
        });
    });
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", craneType];
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

- (void) saveAllConditionsForCrane : (InspectedCrane *) crane
                        Conditions : (NSArray *) conditions;
{
    NSManagedObjectContext *context = [((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:context];

    for (Condition *condition in conditions) {
        CoreDataCondition *coreDataCondition = [[CoreDataCondition alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        coreDataCondition.isDeficient = [NSNumber numberWithBool:condition.deficient];
        coreDataCondition.isApplicable = [NSNumber numberWithBool:condition.applicable];
        coreDataCondition.notes = condition.notes;
        coreDataCondition.optionSelectedIndex = [NSNumber numberWithInteger:condition.pickerSelection];
        coreDataCondition.optionSelected = condition.deficientPart;
        coreDataCondition.inspectedCrane = crane;
    }
    
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
}

- (NSArray *) getAllConditionsForCrane : (InspectedCrane *) crane {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCondition inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inspectedCrane == %@", crane];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        
    }
    
    return fetchedObjects;

}


@end
