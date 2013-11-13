//
//  InspectionViewController.h
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Condition.h"
#import "ItemListConditionStorage.h"

@interface InspectionViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *lblPartNumber;

@property (strong, nonatomic) IBOutlet UILabel *lblPart;
@property (strong, nonatomic) IBOutlet UISwitch *applicableSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *defficiencySwitch;
@property (strong, nonatomic) IBOutlet UITextView *txtNotes;
@property (strong, nonatomic) IBOutlet UIPickerView *defficiencyPicker;
@property (strong, nonatomic) IBOutlet NSArray *pickerData;

@property (strong, nonatomic) IBOutlet UIButton* createCertificateButton;

typedef enum {
    FINAL_SUBMISSION_APPROVED,
    
    
} CurrentState;

- (void) changeLayout : (int) optionLocation
           PartsArray : (NSArray*) myPartsArray
        ItemListStore : (ItemListConditionStorage *) myItemListStore;
- (void) fillOptionArrays : (NSString*) craneDescription;
- (void) initiateParts;
@end