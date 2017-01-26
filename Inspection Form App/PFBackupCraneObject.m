//
//  PFBackupCraneObject.m
//  Inspection Form App
//
//  Created by adeiji on 1/26/17.
//
//

#import "PFBackupCraneObject.h"

@implementation PFBackupCraneObject

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"BackupCraneObject";
}

@end
