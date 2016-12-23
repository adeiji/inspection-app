//
//  InspectionView.h
//  Inspection Form App
//
//  Created by adeiji on 12/23/16.
//
//

#import <UIKit/UIKit.h>

@protocol InspectionDelegate <NSObject>

- (void) didPressLeftArrowKey;
- (void) didPressRightArrowKey;

@end

@interface InspectionView : UIView <UIKeyInput>

@property (nonatomic, weak) id<InspectionDelegate> delegate;

@end
