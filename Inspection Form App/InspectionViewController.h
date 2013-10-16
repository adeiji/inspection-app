//
//  InspectionViewController.h
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import <UIKit/UIKit.h>

@interface InspectionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblPartNumber;

@property (strong, nonatomic) IBOutlet UILabel *lblPart;
@property (strong, nonatomic) IBOutlet UISwitch *applicableSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *defficiencySwitch;
@property (strong, nonatomic) IBOutlet UITextView *txtNotes;
@property (strong, nonatomic) IBOutlet UIPickerView *defficiencyPicker;

@end
