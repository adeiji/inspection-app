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
#import "Inspection_Form_App-Swift.h"

@implementation SyncManager

+ (void) getAllInspectionDetails {
    IACraneInspectionDetailsManagerSwift *manager = [IACraneInspectionDetailsManagerSwift new];
    [manager saveInspectionDetails];
}

@end
