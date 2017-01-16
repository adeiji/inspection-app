//
//  PFInspectionDetails.h
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import <Parse/Parse.h>

@interface PFInspectionDetails : PFObject<PFSubclassing>

+ (NSString *) parseClassName;

@property BOOL isDeficient;
@property BOOL isApplicable;
@property (retain) NSString *notes;
@property int optionSelectedIndex;
@property (retain) NSString *optionSelected;
@property int optionLocation;
@property (retain) NSString *hoistSrl;
@property (retain) PFUser *toUser;
@property (retain) NSString *craneId;

@end
