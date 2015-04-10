//
//  PartSelectionDelegate.h
//  Inspection Form App
//
//  Created by Ade on 11/14/13.
//
//

#import <Foundation/Foundation.h>


@class InspectionPoint;

@protocol PartSelectionDelegate <NSObject>

@required
- (void) selectedPart : (InspectionPoint *) currentPart
    newOptionLocation : (NSInteger) optionLocation;
- (void) selectedOption : (NSString *) selectedOption;

@end
