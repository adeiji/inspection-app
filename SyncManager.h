//
//  SyncManager.h
//  Inspection Form App
//
//  Created by adeiji on 4/1/15.
//
//

#import <Foundation/Foundation.h>
#import "IACraneInspectionDetailsManager.h"
#import "InspectionCrane.h"
#import "AppDelegate.h"

@interface SyncManager : NSObject

+ (void) getAllInspectionDetails;

@end
