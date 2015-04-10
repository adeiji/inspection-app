//
//  PromptView.h
//  Inspection Form App
//
//  Created by adeiji on 4/10/15.
//
//

#import <UIKit/UIKit.h>

@interface PromptView : UIView

@property (weak, nonatomic) IBOutlet UITextField *txtPromptResult;
@property (weak, nonatomic) IBOutlet UILabel *lblPromptText;
@property (strong, nonatomic) NSArray *prompts;
@property int promptLocation;
@end
