//
//  ViewController.h
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "SwitchViewController.h"
#import "TableViewController.h"
#import "AutographViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TextField.h"
#import <DropboxSDK/DropboxSDK.h>

@class DBRestClient;

@interface ViewController : UIViewController
<UIPickerViewDelegate, UIPickerViewDataSource, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate, UIPickerViewAccessibilityDelegate, UITextFieldDelegate, DBRestClientDelegate> { 
    sqlite3 *contactDb; 
    UIDocumentInteractionController *controller;
}

@property (weak, nonatomic) IBOutlet UISwitch *defficiencySwitch;
@property (strong, nonatomic) IBOutlet UIPickerView *DefficiencyPicker;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property CGPoint gestureStartPoint;
@property int optionLocation;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navSubmit;
@property (strong, nonatomic) NSMutableArray* pickerData;
@property (strong, nonatomic) NSMutableArray* pickerDataStorage;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell1;
@property (strong, nonatomic) IBOutlet UIViewController *secondViewController;
@property (strong, nonatomic) IBOutlet UIViewController *firstViewController;
@property (strong, nonatomic) IBOutlet UIViewController *rootViewController;
@property (strong, nonatomic) IBOutlet TableViewController *viewAllController;
@property (strong, nonatomic) IBOutlet AutographViewController *autographController;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;
@property (weak, nonatomic) IBOutlet UITableView *myPartsTable;
@property (strong, nonatomic) NSMutableArray *myPartsArray;
@property (weak, nonatomic) IBOutlet UILabel *lblPartNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblPart;
@property (weak, nonatomic) IBOutlet UITableView *partsTable;
@property (weak, nonatomic) IBOutlet TextField *txtCustomerName;
@property (weak, nonatomic) IBOutlet TextField *txtCustomerContact;
@property (weak, nonatomic) IBOutlet TextField *txtJobNumber;
@property (weak, nonatomic) IBOutlet TextField *txtAddress;
@property (weak, nonatomic) IBOutlet TextField *txtEquipDesc;
@property (weak, nonatomic) IBOutlet TextField *txtCraneMfg;
@property (weak, nonatomic) IBOutlet TextField *txtHoistMfg;
@property (weak, nonatomic) IBOutlet TextField *txtHoistMdl;
@property (weak, nonatomic) IBOutlet TextField *txtCap;
@property (weak, nonatomic) IBOutlet TextField *txtCraneSrl;
@property (weak, nonatomic) IBOutlet TextField *txtHoistSrl;
@property (weak, nonatomic) IBOutlet TextField *txtEquipNum;
@property (weak, nonatomic) IBOutlet UITextView *txtNotes;
@property (weak, nonatomic) IBOutlet TextField *txtEmail;
@property (strong, nonatomic) NSString *customerName;
@property (strong, nonatomic) NSString *jobnumber;
@property (strong, nonatomic) IBOutlet UIViewController *viewPDFController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openInButton;
@property (weak, nonatomic) IBOutlet UITextField *txtCraneDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtTechnicianName;
@property (weak, nonatomic) IBOutlet UILabel *lblCraneDesc;
@property (weak, nonatomic) IBOutlet UISwitch *applicableSwitch;


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
- (void) createDatabase;
- (void) createTable:(NSString *) customerName;
- (void) userDidClickTable;
- (IBAction) partsListButtonClicked:(id) sender;
- (IBAction) textFieldDidBeginEditing:(UITextField *) textField;
- (IBAction) textFieldDidEndEditing:(UITextField *) textField;
- (IBAction) textViewDidBeginEditing:(UITextView *)textView;
- (IBAction)NewCustomerPress:(id)sender;
- (IBAction)GetOrderFromJobNumber:(id)sender;
- (IBAction)openInClicked:(id)sender;
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller;
- (IBAction)finalBackButtonPressed:(id)sender;
- (IBAction)dateSelected:(id)sender;
- (IBAction)GoHome:(id)sender;
- (IBAction)NASwitchChanged:(id)sender;
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;



@end
