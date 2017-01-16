//
//  Condition.h
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InspectionOption.h"

@interface Condition : NSObject

@property (strong, nonatomic) NSString *notes;
@property BOOL deficient;
@property NSInteger *pickerSelection;
@property (strong, nonatomic) NSString *deficientPart;
@property BOOL applicable;
@property NSInteger optionLocation;

- (Condition *) initWithParameters : (NSString *) myNotes
                       Defficiency : (BOOL) myDeficient
                   PickerSelection : (NSUInteger *) myPickerSelection
                     DeficientPart : (NSString *) myDeficientPart
                        Applicable : (BOOL) myApplicable;

@end
