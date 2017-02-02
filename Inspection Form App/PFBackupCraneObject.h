//
//  PFBackupCraneObject.h
//  Inspection Form App
//
//  Created by adeiji on 1/26/17.
//
//

#import <Parse/Parse.h>
#import "PFCrane.h"

@interface PFBackupCraneObject : PFObject <PFSubclassing>

@property (retain) PFUser *user;
@property (retain) PFCrane *crane;

@end
