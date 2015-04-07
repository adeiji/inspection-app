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
#import "PartSelectionDelegate.h"
#import "InspectionBussiness.h"

@interface InspectionViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, PartSelectionDelegate, UIDocumentInteractionControllerDelegate>
{

    int timesShown;
    BOOL pageSubmitAlertView;
    BOOL inspectionComplete;
    BOOL loadRatings;
    BOOL remarksLimitations;
    BOOL finished;
    BOOL proofLoad;
    BOOL testLoad;
    BOOL proofLoadDescription;
    Inspection *inspection;
    ItemListConditionStorage *itemListStore;
    NSString *overallRating;
    NSArray *_deficiencyPickerArray;
    
}

@property (strong, nonatomic) IBOutlet UILabel *lblPartNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblPart;
@property (strong, nonatomic) IBOutlet UISwitch *applicableSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *deficiencySwitch;
@property (strong, nonatomic) IBOutlet UITextView *txtNotes;
@property (strong, nonatomic) IBOutlet UIPickerView *deficiencyPicker;
@property (strong, nonatomic) IBOutlet NSArray *pickerData;
@property (strong, nonatomic) NSString *craneType;
@property (strong, nonatomic) NSArray *partsArray;
@property BOOL validated;

@property (strong, nonatomic) IBOutlet UIButton* createCertificateButton;
@property int optionLocation;
typedef enum {
    FINAL_SUBMISSION_APPROVED,
} CurrentState;

- (void) changeLayout : (int) optionLocation
           PartsArray : (NSArray*) myPartsArray
        ItemListStore : (ItemListConditionStorage *) myItemListStore;
- (void) fillOptionArrays : (InspectionPoint *) craneDescription;
- (void) initiateParts;
- (IBAction)createCertificateButtonPressed:(id)sender;

//Action Outlets
- (IBAction)gotoCustomerInformation:(id)sender;

@end
