//
//  DELoginManager.m
//  Inspection Form App
//
//  Created by adeiji on 2/22/16.
//
//

#import "DELoginManager.h"

@implementation DELoginManager

- (NSArray *) getAllUsers {
    PFQuery *query = [PFUser query];
    NSError *error;
    NSArray *users = [query findObjects:&error];
    return users;
}

@end
