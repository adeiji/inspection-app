//
//  Options.h
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionPoint.h"

#ifndef Inspection_Form_App_Options_h
#define Inspection_Form_App_Options_h

#endif

@interface Options : NSObject
    
@property (strong, nonatomic)  NSArray* optionsArray;
    
- (id) initWithPart : (InspectionPoint *) part;
- (NSMutableArray *) myOptionsArray;


@end