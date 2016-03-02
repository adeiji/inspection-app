//
//  PFInspectionDetails.m
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import "PFInspectionDetails.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFInspectionDetails

@dynamic isDeficient;
@dynamic isApplicable;
@dynamic notes;
@dynamic optionSelectedIndex;
@dynamic optionSelected;
@dynamic optionLocation;
@dynamic hoistSrl;
@dynamic sentToUser;

+ (NSString *) parseClassName {
    return @"InspectionDetails";
}

+ (void) load {
    [self registerSubclass];
}

@end
