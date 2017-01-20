//
//  IAAddSignatureView.h
//  Inspection Form App
//
//  Created by adeiji on 1/17/17.
//
//

#import <UIKit/UIKit.h>
#import "IAConstants.h"

@interface IAAddSignatureView : UIView

@property (strong, nonatomic) UIImageView *mainImage;
@property (strong, nonatomic) UIImageView *tempDrawImage;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *saveButton;

- (void) createSaveButton;

@end
