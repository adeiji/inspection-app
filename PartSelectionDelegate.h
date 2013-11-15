//
//  PartSelectionDelegate.h
//  Inspection Form App
//
//  Created by Ade on 11/14/13.
//
//

#import <Foundation/Foundation.h>


@class Part;

@protocol PartSelectionDelegate <NSObject>

@required
- (void) selectedPart : (Part *) currentPart;
- (void) selectedOption : (NSString *) selectedOption;

@end
