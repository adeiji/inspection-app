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

    PFQuery *query = [PFQuery queryWithClassName:PARSE_CLASS_CRANE];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [[IACraneInspectionDetailsManager sharedManager] setCranes:objects];
        
    }];
}


@end
