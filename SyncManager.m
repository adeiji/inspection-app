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
            [[IACraneInspectionDetailsManager sharedManager] saveInspectionDetailsWithCranes:objects];
        }
    }];
}

@end
