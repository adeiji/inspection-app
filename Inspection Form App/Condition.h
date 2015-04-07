//
//  Condition.h
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InspectionPoint.h"

@interface Condition : NSObject

@property (strong, nonatomic) NSString *notes;
@property BOOL deficient;
@property NSUInteger pickerSelection;
@property (strong, nonatomic) InspectionPoint *deficientPart;
@property BOOL applicable;

- (Condition *) initWithParameters : (NSString *) myNotes
                       Defficiency : (BOOL) myDeficient
                   PickerSelection : (NSUInteger *) myPickerSelection
                     DeficientPart : (InspectionPoint *) myDeficientPart
                        Applicable : (BOOL) myApplicable;

@end
