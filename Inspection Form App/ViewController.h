//
//  ViewController.h
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TextField.h"
#import <Dropbox/Dropbox.h>
#import "GradientView.h"
#import "InspectionViewController.h"
#import "IACraneInspectionDetailsManager.h"
#import "InspectionCrane.h"
#import "IAConstants.h"

@class DBRestClient;

@interface ViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIPickerViewAccessibilityDelegate, UITextFieldDelegate> {
    sqlite3 *contactDb; 
    UIDocumentInteractionController *controller;
    UIDocumentInteractionController *secondController;
    ItemListConditionStorage *myItemListStore;
    DBRestClient *restClient;
    Parts* parts;
    sqlite3 *contactDB;
    NSString *databasePath;
    NSString *tableName;
    int *deficient;
    int timesShown;
    NSString *deficientPart;
    NSString *notes;
    NSString *pickerSelection;
    UIScrollView *theScrollView;
    UITextField *activeField;
    BOOL pageSubmitAlertView;
    NSString *overallRating;
    NSString *technicianName;
    NSString *manufacturer;
    NSString *testLoads;
    NSString *proofLoadDescription;
    NSString *loadRatingsText;
    NSString *remarksLimitationsImposed;
    bool testLoad;
    bool loadRatings;
    bool remarksLimitations;
    bool finished;
    bool proofLoad;
    bool inspectionComplete;
    NSString *owner;
    bool changeLayoutNeeded;
    NSString* iosVersion;
    Inspection *inspection;
    int currentOrientation;
}

//Dropbox Objects
@property (strong, nonatomic) DBAccount *account;
@property (strong, nonatomic) DBDatastore *dataStore;
@property (strong, nonatomic) DBTable *table;

- (IBAction)test:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property int optionLocation;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navSubmit;
@property (strong, nonatomic) IBOutlet GradientView *craneView;


@property (strong, nonatomic)  InspectionViewController* inspectionViewController;
@property (strong, nonatomic) IBOutlet UIScrollView *CustomerInfoScrollView;
@property (strong, nonatomic) IBOutlet UIView *CraneInspectionView;
@property (weak, nonatomic) IBOutlet UIView *CustomerInfoView;
@property (strong, nonatomic) IBOutlet UIView *CustomerInfoFullView;
@property (strong, nonatomic) IBOutlet UIViewController *rootViewController;
@property (strong, nonatomic) NSMutableArray *myPartsArray;

@property (weak, nonatomic) IBOutlet TextField *txtCustomerName;
@property (weak, nonatomic) IBOutlet TextField *txtCustomerContact;
@property (weak, nonatomic) IBOutlet TextField *txtJobNumber;
@property (weak, nonatomic) IBOutlet TextField *txtAddress;
@property (weak, nonatomic) IBOutlet TextField *txtCraneMfg;
@property (weak, nonatomic) IBOutlet TextField *txtHoistMfg;
@property (weak, nonatomic) IBOutlet TextField *txtHoistMdl;
@property (weak, nonatomic) IBOutlet TextField *txtCap;
@property (weak, nonatomic) IBOutlet TextField *txtCraneSrl;
@property (weak, nonatomic) IBOutlet TextField *txtHoistSrl;
@property (weak, nonatomic) IBOutlet TextField *txtEquipNum;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDropboxLink;
@property (weak, nonatomic) IBOutlet UITextView *txtNotes;
@property (weak, nonatomic) IBOutlet TextField *txtEmail;
@property (strong, nonatomic) NSString *customerName;
@property (strong, nonatomic) NSString *jobnumber;
@property (strong, nonatomic) IBOutlet UIViewController *viewPDFController;
@property (weak, nonatomic) IBOutlet UITextField *txtCraneDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtTechnicianName;
@property (weak, nonatomic) IBOutlet UILabel *lblCraneDesc;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CreateCertificateButton;
@property (strong, nonatomic) IBOutlet UIPickerView *craneDescriptionPickerView;
@property (strong, nonatomic) NSMutableArray *craneDescriptionsArray;
@property (weak, nonatomic) IBOutlet UIButton *selectCraneButton;

typedef enum {
    INVALID_CHARACTER,
    EMPTY_FIELD,
    PASSED
} ValidationResults;

- (IBAction)SelectCraneDescriptionPressed:(id)sender;
- (IBAction)UpdateButtonPressed:(id)sender;
- (IBAction)LoadEquipNumPressed:(id)sender;
- (IBAction)LoadHoistSrlPressed:(id)sender;
- (IBAction)ViewAllOrders:(id)sender;
- (IBAction)gotoCustomerInfo:(id)sender;
- (IBAction)CustomerSubmitPressed:(id)sender;
- (IBAction)nextPressed;
- (IBAction)previousPressed;
- (IBAction)switchView;
- (IBAction)datePressed:(id)sender;
- (IBAction)submitPressed:(id)sender;
- (IBAction)buttonPressed;
- (IBAction)switchChanged:(id)sender;
- (void) createTable:(NSString *) customerName;
- (void) userDidClickTable;
- (IBAction) partsListButtonClicked:(id) sender;
- (IBAction) textFieldDidBeginEditing:(UITextField *) textField;
- (IBAction) textFieldDidEndEditing:(UITextField *) textField;
- (IBAction) textViewDidBeginEditing:(UITextView *)textView;
- (IBAction)NewCustomerPress:(id)sender;
- (IBAction)GetOrderFromJobNumber:(id)sender;
- (IBAction) didPressLink;
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller;
- (IBAction)finalBackButtonPressed:(id)sender;
- (IBAction)dateSelected:(id)sender;
- (IBAction)NASwitchChanged:(id)sender;
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (IBAction)CreateCertificate:(id)sender;

- (NSDictionary *) createCraneDictionary;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;



@end
