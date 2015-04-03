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

/*
 
 Store all the cranes, and their inspection details to the database
 
 */
- (void) saveInspectionDetailsWithCranes : (NSArray *) cranes {
//    [self resetInspectionDetailsDatabase];
    NSManagedObjectContext *context =  ((AppDelegate *)[ [UIApplication sharedApplication] delegate]).managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:context];
    /* Get every crane that we just received from the server and grab all it's subdocuments and store them into coredata */
    for (id crane in cranes) {
        InspectionCrane *craneObject = [[InspectionCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        craneObject.name = [crane objectForKey:kObjectName];
        // Convert the Parse Crane Object into a Core Data Object
        NSSet *set = [[NSSet alloc] init];
        [set setByAddingObjectsFromArray:[crane objectForKey:kInspectionPoints]];
        NSMutableArray *inspectionPoints = [NSMutableArray new];
        
        for (id inspectionPoint in craneObject.inspectionPoints) {
            // Create Core Data objects for all the inspcetion points
            NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectionPoint inManagedObjectContext:context];
            InspectionPoint *inspectionPointObject = [[InspectionPoint alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
            inspectionPointObject.name = [inspectionPoint objectForKey:kObjectName];
            [set setByAddingObjectsFromArray:[inspectionPoint objectForKey:kOptions]];
            inspectionPointObject.inspectionOptions = set;
            [inspectionPoints addObject:inspectionPointObject];
            
            NSMutableArray *options = [NSMutableArray new];
            for (id option in inspectionPointObject.inspectionOptions) {
                NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassInspectionOption inManagedObjectContext:context];
                InspectionOption *inspectionOptionObject = [[InspectionOption alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                inspectionOptionObject.name = [option objectForKey:kObjectName];
                [options addObject:inspectionOptionObject];
            }
        }
    }
    
    [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
    [self loadAllInspectionDetails];
}


/*
 
 Get all the inspection details from the Database
 
 */

- (NSArray *) getInspectionDetails {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:_context];
    [fetchRequest setEntity:entity];
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



@end
