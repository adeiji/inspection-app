//
//  SyncManager.m
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import "SyncManager.h"
#import <Parse/Parse.h>
#import "IAConstants.h"

@implementation SyncManager

+ (void) getAllInspectionDetails {

    PFQuery *query = [PFQuery queryWithClassName:kParseClassCrane];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (id crane in objects) {
                // Convert the Parse Crane Object into a Core Data Object
                NSManagedObjectContext *context =  ((AppDelegate *)[ [UIApplication sharedApplication] delegate]).managedObjectContext;
                NSEntityDescription *entity = [NSEntityDescription entityForName:kCoreDataClassCrane inManagedObjectContext:context];
                InspectionCrane *craneObject = [[InspectionCrane alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                craneObject.name = [crane objectForKey:kObjectName];
                NSSet *set = [[NSSet alloc] init];
                [set setByAddingObjectsFromArray:[crane objectForKey:kInspectionPoints]];
                craneObject.inspectionPoints = set;
            }
        }
    }];
}


@end
