//
//  InspectionView.m
//  Inspection Form App
//
//  Created by adeiji on 12/23/16.
//
//

#import "InspectionView.h"

@implementation InspectionView 


- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) deleteBackward {

}

- (BOOL) hasText {
    return YES;
}

-(void) insertText:(NSString *)text
{
    
    static NSDate *lastKeypress;
    NSTimeInterval lastKeypressInterval = [lastKeypress timeIntervalSince1970];
    NSDate *thisKeypress = [NSDate date];
    NSTimeInterval thisKeypressInterval = [thisKeypress timeIntervalSince1970];
    if (thisKeypressInterval > lastKeypressInterval + 0.5)
    {
        lastKeypress = thisKeypress;
        if ([text isEqualToString:@"\\"])
        {
            [_delegate didPressRightArrowKey];
            
        }
        if ([text isEqualToString:@"]"])
        {
            [_delegate didPressLeftArrowKey];
        }
    }
}

@end
