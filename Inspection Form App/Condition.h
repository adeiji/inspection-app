//
//  Condition.h
//  Inspection Form App
//
//  Created by Developer on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Condition : NSObject {
    NSString *notes;
    BOOL deficient;
    NSUInteger *pickerSelection;
    NSString *deficientPart;
    BOOL applicable;
}

- (id) initWithParameters:(NSString *) myNotes: (BOOL) myDeficient: (NSUInteger *) myPickerSelection: (NSString *) myDeficientPicker: (BOOL) myApplicable;
- (NSString *) notes;
- (BOOL) deficient;
- (NSUInteger *) pickerSelection;
- (NSString *) deficientPart;
- (BOOL) applicable;

- (void) setNotes:(id) input;
- (void) setDeficient:(BOOL) input;
- (void) setPickerSelection: (NSUInteger *) input;
- (void) setDeficientPart:(NSString *) input;
- (void) setApplicable: (BOOL) input;
@end
