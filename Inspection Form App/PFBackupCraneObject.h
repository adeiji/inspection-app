//
//  PFBackupCraneObject.h
//  Inspection Form App
//
//  Created by adeiji on 1/26/17.
//
//

#import <Parse/Parse.h>
#import "PFCrane.h"

@interface PFBackupCraneObject : PFObject

@property (retain) PFUser *toUser;
@property (retain) PFCrane *crane;

@end
