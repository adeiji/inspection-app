//
//  ViewController.m
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Customer.h"
#import "OptionList.h"
#import "Options.h"
#import "CoreGraphics/CoreGraphics.h"
#import "GradientView.h"
#import "Parts.h"
#import "Condition.h"
#import "sqlite3.h"
#import "TableViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "UIKit/UIkit.h"
#import <Dropbox/Dropbox.h>
#import "OrdinalNumberFormatter.h"
#import "Foundation/NSDateFormatter.h"
#import "DataLayer.h"
#import "InspectionViewController.h"
#import "InspectionBussiness.h"
#import "AppDelegate.h"
#import "InspectionManager.h"
#import "OptionsTableViewController.h"
#import "Inspection_Form_App-Swift.h"

@interface ViewController ()
@end

@implementation ViewController


#define kMinimumGestureLength   25
#define kMaximumVariance        100

static NSString* USERNAME = @"username";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self editInspectionViewController];

    inspection = [[Inspection alloc] init];
    
    changeLayoutNeeded = NO;
    iosVersion = [[UIDevice currentDevice] systemVersion];
    [self addObservers];
    _craneDescriptionsArray = [[IACraneInspectionDetailsManager sharedManager] cranes];
    [self setupTxtDate];
    [self dateSelectionChanged:_datePicker];
    
    _optionLocation=0;
    [self resetVariables];
    _txtTechnicianName.text = [owner uppercaseString];
    [self initiatePartsForSelectedCrane];
    
    if ([UtilityFunctions getUserId]) {
        NSString *username = [UtilityFunctions getUsername];
        
        if (username != nil) {
            self.txtTechnicianName.text = [username uppercaseString];
        }
    }    
}

- (void) setIsCraneSet : (BOOL) value {
    isCraneSet = value;
}

- (IBAction)showOptionsMenu:(id)sender {
    OptionsTableViewController *optionsTableViewController = [[OptionsTableViewController alloc] init];
    optionsTableViewController.options = [NSArray arrayWithObjects:@"Send Inspection", @"View Inspections Shared With You", @"Account", @"Add/Edit Signature", @"Backup Data to Cloud", @"Load Water District Cranes", @"Transfer Data From Parse To Firebase", nil];
    [self.navigationController pushViewController:optionsTableViewController animated:true];
}


- (void) initiatePartsForSelectedCrane {
    if ([_craneDescriptionsArray count] > 0)
    {
        NSInteger selectedRow = [_craneDescriptionPickerView selectedRowInComponent:0];
        _inspectionViewController.optionLocation = 0;
        InspectionCrane *crane = [_craneDescriptionsArray objectAtIndex:selectedRow];
        [[IACraneInspectionDetailsManager sharedManager] setCrane:crane];
        [_inspectionViewController initiateParts];
    }
}

- (void) addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetCraneTypePickerView) name:NOTIFICATION_CRANE_DETAILS_FINISHED_SAVING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayCraneInformation:) name:NOTIFICATION_HOISTSRL_SELECTED object:nil];
    //Keyboard manipulation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) displayCraneInformation : (NSNotification *) notification {
    
    InspectedCrane *crane = [notification.userInfo objectForKey:kSelectedInspectedCrane];
    
    _txtCap.text = crane.capacity;
    _txtCraneSrl.text = crane.craneSrl;
    _txtEquipNum.text = crane.equipmentNumber;
    _txtHoistMdl.text = crane.hoistMdl;
    _txtHoistMfg.text = crane.hoistMfg;
    _txtHoistSrl.text = crane.hoistSrl;
    _txtCraneMfg.text = crane.mfg;
    
    Customer *customer = crane.customer;
    if (customer) {
        _txtCustomerName.text = customer.name;
        _txtCustomerContact.text = customer.contact;
        _txtAddress.text = customer.address;
        _txtEmail.text = customer.email;
    }
    
    int counter = 0;
    for (InspectionCrane *myCrane in _craneDescriptionsArray) {
        if ([[myCrane.name lowercaseString] isEqualToString:[crane.type lowercaseString]])
        {
            [_craneDescriptionPickerView selectRow:counter inComponent:0 animated:YES];
        }
        
        counter ++;
    }
}

- (void) resetCraneTypePickerView {
    _craneDescriptionsArray = [[IACraneInspectionDetailsManager sharedManager] cranes];
    _btnSync.enabled = YES;
    [_craneDescriptionPickerView reloadAllComponents];
}

- (void) setupTxtDate
{
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btnSelectDate = [[UIButton alloc] init];
    
    [btnSelectDate addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchDown];
    NSDate *now = [NSDate date];
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [_datePicker setDate:now animated:NO];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    [_datePicker addTarget:self action:@selector(dateSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    _txtDate.inputView = _datePicker;
}

//Every time the date selection changes it will also change in the text box
- (void) dateSelectionChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    _txtDate.text = [dateFormatter stringFromDate:[_datePicker date]];
}

//When the view is loaded there are specific variables that we want to be reset to force the user to have to renter them, or to refresh.
- (void) resetVariables
{
    overallRating = @"";
    _txtTechnicianName.text = technicianName;
    manufacturer = @"";
    testLoads =  @"";
    proofLoadDescription = @"";
    loadRatingsText = @"";
    remarksLimitationsImposed = @"";
}


- (void) editInspectionViewController
{
    _inspectionViewController = [[UIStoryboard storyboardWithName:@"iPadMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inspectionViewController"];
    _inspectionViewController.optionLocation = 0;
}

#pragma mark - Dropbox Datastore Methods

//If there is not a Dropbox Datastore Table already created, we create it, as well as the data store.
- (void) createDatastoreTable
{
    
    _account = [[DBAccountManager sharedManager] linkedAccount];
    _dataStore = [DBDatastore openDefaultStoreForAccount:_account error:nil];
    _table = [_dataStore getTable:@"inspections"];
    
    //Set the account and datastore objects for the singleton object
    [[InspectionManager sharedManager] setDropboxAccount:_account];
    [[InspectionManager sharedManager] setDataStore:_dataStore];
    [[InspectionManager sharedManager] setTable:_table];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark TextField Methods

//When you begin editing any text field this method is called in order to tell the compiler which text field is currently in focus
//so that it is known where the screen needs to scroll to, to show the text box when it is being edited also so that we can set the text to all capitalized.
- (IBAction) textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}
//memmory management
- (IBAction) textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

#pragma mark Database Methods


//gets customer information and crane information from the JOBS table with the specified equip # and then displays this information on the home page

- (IBAction)syncCraneInspectionDetails:(id)sender {
    _btnSync.enabled = NO;
    [SyncManager getAllInspectionDetails];
    
}

- (void) updateUserDefaultsToSynced {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kSyncedFromDatabase];
    [userDefaults synchronize];
    
}

- (void) LoadEquipNumPressed:(id)sender
{
    [self EmptyTextFields];
}


//Grab the crane information from the WATERDISTRICTCRANES table with the HoistSrl as the identifier and then insert the results onto the home page
//Automatically insert the customerName, customerContact, Address and Email
- (IBAction) LoadHoistSrlPressed : (id) sender
{
    NSDictionary *query = [[NSDictionary alloc] initWithObjectsAndKeys:@"hoistsrl", _txtHoistSrl.text, nil];
    
    inspection.itemList.myConditions = [[NSMutableArray alloc] initWithArray:[InspectionBussiness getRecords:query DBAccount:_account DBDatastore:_dataStore DBTable:_table]];
    
    [self OpenOrderFromField:_txtHoistSrl];
}


//this method will need to open the order by getting both the hoist srl number or equip number and the job number so that they can get any hoist srl at any time
- (void) OpenOrderFromField: (UITextField *) input;
{
    
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

//When the correct date is selected from the DatePicker then this method will convert the long date to the short date
//ex: April 12, 2012 = 4/12/12
- (IBAction)dateSelected:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString * date = [[NSString alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    date = [dateFormatter stringFromDate:_datePicker.date];
    _txtDate.text = date;
    
    [_txtDate resignFirstResponder];
    date = nil;
    dateFormatter= nil;
}


#pragma mark - Textfield Delegate Methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]]; return NO;
}


- (IBAction)buttonPressed {
    NSDate *myDate = [_datePicker date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [format stringFromDate:myDate];
    NSLog (@"date: %@", dateString);
    _txtDate.text = dateString;
    [_datePicker removeFromSuperview];
    dateString = nil;
    myDate = nil;
    format = nil;
}

- (IBAction)datePressed:(id)sender {
    //btnSelectDate.hidden = NO;
}

- (ValidationResults) validateSubmission : (BOOL) showResults
{
    if ([_txtHoistSrl.text isEqualToString:@""] ||
        [_txtTechnicianName.text isEqualToString:@""] ||
        [_txtCustomerName.text isEqualToString:@""] ||
        [_txtCustomerContact.text isEqualToString:@""] ||
        [_txtJobNumber.text isEqualToString:@""] ||
        [_txtDate.text isEqualToString:@""] ||
        [_txtAddress.text isEqualToString:@""] ||
        [_txtEmail.text isEqualToString:@""] ||
        [_txtEquipNum.text isEqualToString:@""] ||
        [_txtCraneMfg.text isEqualToString:@""] ||
        [_txtHoistMfg.text isEqualToString:@""] ||
        [_txtHoistMdl.text isEqualToString:@""] ||
        [_txtCraneSrl.text isEqualToString:@""] ||
        [_txtCap.text isEqualToString:@""])
    {

        return EMPTY_FIELD;
     
    }
    else if ([_txtHoistSrl.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtTechnicianName.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtCustomerName.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtCustomerContact.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtJobNumber.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtDate.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtAddress.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtEmail.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtEquipNum.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtCraneMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtHoistMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtHoistMdl.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtCraneSrl.text rangeOfString:@"\""].location != NSNotFound ||
             [_txtCap.text rangeOfString:@"\""].location != NSNotFound)
    {
        return INVALID_CHARACTER;
    }
    
    return PASSED;
}



//On the deficiency information pages, when you press the submit button
- (void) showValidationResults : (ValidationResults) results {
    //First we check to see if any of the fields in the customerInfo page and if there are any empty fields then the user is not allowed to submit the information and a UIAlertView pops up telling you that there are fields where nothing was inserted into the fields
    if (results == EMPTY_FIELD)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Customer Error" message:@"All Values On the Customer Screen Must Be Entered" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    } //checks to see if there are any quotation marks inside of any of the fields, and if there are any then the user is not allowed to enter the customer, and a UIAlertView pops up telling you this
    else if (results == INVALID_CHARACTER)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Customer Error" message:@"Can Not Enter Characters 'quotation mark' ' \" ' Into Any Field!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}



//Create the crane from the info that has been inserted into the text boxes.  This crane will then be passed to the InspectionViewController.
- (InspectedCrane *) createCrane
{
    InspectedCrane *crane = [[InspectedCrane alloc] init];
    
    crane.hoistSrl = _txtHoistSrl.text;
    crane.equipmentNumber = _txtEquipNum.text;
    // Need to get the crane type
    crane.capacity = _txtCap.text;
    crane.craneSrl = _txtCraneSrl.text;
    crane.hoistMdl = _txtHoistMdl.text;
    crane.hoistMfg = _txtHoistMfg.text;
    crane.mfg = _txtCraneMfg.text;
    
    return crane;
}
//Create the customer from the info that has been inserted into the text boxes.  This customer will then be passed to the InspectionViewController.
- (Customer*) createCustomer
{
    Customer *customer = [[Customer alloc] init];
    
    customer.name = _txtCustomerName.text;
    customer.contact = _txtCustomerContact.text;
    customer.address = _txtAddress.text;
    customer.email = _txtEmail.text;
    
    return customer;
}
//Create the inspection that will be read from.
- (void) createInspection : (InspectedCrane *) crane
                 Customer : (Customer *) customer
{
    inspection = [[Inspection alloc] init];
    
    inspection.technicianName = _txtTechnicianName.text;
    inspection.date = _txtDate.text;
    inspection.jobNumber = _txtJobNumber.text;
    inspection.inspectedCrane = crane;
    inspection.customer = customer;
    inspection.itemList = myItemListStore;
}

//Enters a new crane into the dropbox datastore
- (void)InsertCraneIntoTable
{
    
}
- (void)InsertOwnerIntoTable:(NSString *) myOwner
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    documentsDir = [paths objectAtIndex:0];
    
    //full file location string
    databasePath = [[NSString alloc] initWithString:[documentsDir stringByAppendingPathComponent:@"contacts.db"]];
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO IPADOWNER (NAME) VALUES(\"%@\");",
                               myOwner];
    
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, nil);
        
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table: IPADOWNER");
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
}


- (void) storeInspectionJobInformationWithCraneType : (NSString *) craneType
                                        SelectedRow : (NSInteger) selectedRow
{
    //Here we create all the necessary objects to store the customer and the crane information so that this can be saved to a singleton object and accessed from anywhere.
    Customer *customer = [InspectionBussiness createCustomer:_txtCustomerName.text CustomerContact:_txtCustomerContact.text CustomerAddress:_txtAddress.text CustomerEmail:_txtEmail.text];
    
    InspectedCrane *crane = [[IACraneInspectionDetailsManager sharedManager] createCrane:_txtHoistSrl.text CraneType:craneType EquipmentNumber:_txtEquipNum.text CraneMfg:_txtCraneMfg.text hoistMfg:_txtHoistMfg.text CraneSrl:_txtCraneSrl.text Capacity:_txtCap.text HoistMdl:_txtHoistMdl.text];
    [crane setCustomer:customer];
    
    inspection.inspectedCrane = crane;
    inspection.customer = customer;
    
    inspection.jobNumber = _txtJobNumber.text;
    inspection.date = _txtDate.text;
    inspection.technicianName = _txtTechnicianName.text;
    //Set the objects on the singleton object
    [[InspectionManager sharedManager] setCrane:crane];
    [[InspectionManager sharedManager] setCustomer:customer];
}



- (IBAction)partsListButtonClicked:(id)sender{
    NSInteger selectedRow = [_craneDescriptionPickerView selectedRowInComponent:0];

    if ([self validateSubmission:NO] == PASSED)
    {
        _inspectionViewController.validated = YES;
    }
    if ([_craneDescriptionsArray count] > 0)
    {
        InspectionCrane *selectedCrane = [_craneDescriptionsArray objectAtIndex:selectedRow];
        [self storeInformationAndDisplayInspectionViewWithCrane:selectedCrane SelectedRow:selectedRow];        
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Cranes" message:@"Sorry, but there's no cranes to select.  Click Sync Crane Details" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) storeInformationAndDisplayInspectionViewWithCrane : (InspectionCrane *) selectedCrane
                                               SelectedRow : (NSInteger) selectedRow
{
    if (isCraneSet)
    {
        Parts *craneParts = [[Parts alloc] init: selectedCrane];
        _myPartsArray = [craneParts myParts];
        _inspectionViewController.craneType = selectedCrane.name;
        _inspectionViewController.partsArray = _myPartsArray;
        
        [self storeInspectionJobInformationWithCraneType:selectedCrane.name SelectedRow:selectedRow];
        inspection = [self createInspectionObjectWithSelectedCrane:selectedCrane];
        [[InspectionManager sharedManager] setInspection:inspection];
        [[IACraneInspectionDetailsManager sharedManager] setCrane:selectedCrane];
        
        [self.navigationController pushViewController:_inspectionViewController animated:YES];
        
        /* Send out a notification that the InspectionViewController is pushed onto the stack.
        Send the crane type that is being pushed. */
        [[NSNotificationCenter defaultCenter] postNotificationName:kInspectionViewControllerPushed
                                                            object:self
                                                          userInfo:@{ USER_INFO_SELECTED_CRANE_INSPECTION_POINTS : selectedCrane.inspectionPoints }];
    }
    else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Crane Type" message:@"Please Select the Crane Type" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
 
 On the customer page, submits the information into the database on the iPad
 
 */
- (IBAction)CustomerSubmitPressed:(id)sender {
    
    if ([self validateSubmission : YES] != EMPTY_FIELD || INVALID_CHARACTER)
    {
        _optionLocation = 0;
        // Get the selected crane type fromt he crane picker.
        NSInteger selectedRow = [_craneDescriptionPickerView selectedRowInComponent:0];
        NSNumber *selectedRowObject = [NSNumber numberWithInteger:selectedRow];
        if (selectedRowObject)
        {
            InspectionCrane *selectedCrane = [_craneDescriptionsArray objectAtIndex:selectedRow];
            [self storeInformationAndDisplayInspectionViewWithCrane:selectedCrane SelectedRow:selectedRow];
            [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
            _inspectionViewController.validated = YES;
        }
        else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Crane" message:@"Sorry, but there's no cranes to select." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Errors on Page" message:@"There is an error on the customer page. Can not submit" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

-(void) didReceiveMemoryWarning
{
    NSLog(@"Memory warning received, but ignored due to fact that this program does not consume that much memory.");
}

- (IBAction)buttonPressed:(id)sender {
}
//Create a dictionary that will store the customer information that will then be stored in our Dropbox datastore.
- (NSDictionary *) createCustomerDictionary
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:_txtCustomerName.text, @"customerName",
                                _txtAddress.text, @"address",
                                _txtCustomerContact.text, @"customercontact",
                                _txtCustomerName.text, @"customername",
                                _txtEmail.text, @"email", nil];
    
    return dictionary;
}

- (Inspection *) createInspectionObjectWithSelectedCrane : (InspectionCrane *) selectedCrane {
    Customer *customer = [InspectionBussiness createCustomer:_txtCustomerName.text CustomerContact:_txtCustomerContact.text CustomerAddress:_txtAddress.text CustomerEmail:_txtEmail.text];
    InspectedCrane *crane = [[IACraneInspectionDetailsManager sharedManager] createCrane:_txtHoistSrl.text CraneType:selectedCrane.name EquipmentNumber:_txtEquipNum.text CraneMfg:_txtCraneMfg.text hoistMfg:_txtHoistMfg.text CraneSrl:_txtCraneSrl.text Capacity:_txtCap.text HoistMdl:_txtHoistMdl.text];
    inspection.inspectedCrane = crane;
    inspection.customer = customer;
    inspection.inspectedCrane.craneDescription = selectedCrane.name;
    inspection.jobNumber = _txtJobNumber.text;
    inspection.date = _txtDate.text;
    inspection.technicianName = _txtTechnicianName.text;
    inspection.loadRatings = @"";
    inspection.testLoad = @"";
    inspection.remarksLimitations = @"";
    inspection.proofLoad = @"";
    _inspectionViewController.craneType = inspection.inspectedCrane.type;
    _inspectionViewController.partsArray = _myPartsArray;
    
    [[InspectionManager sharedManager] setInspection:inspection];
    
    return inspection;
}


- (BOOL) shouldAutorotate
{
    return YES;
}

- (void) keyboardWasShown:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    CGRect aRect = self.view.frame;
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Adjust the bottom content inset of your scroll view by the keyboard height
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    aRect.size.width -=keyboardSize.height;

    if (!CGRectContainsPoint(aRect, activeField.superview.frame.origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, keyboardSize.width + activeField.superview.frame.size.width);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }

}
- (void) keyboardWillBeHidden:(NSNotification *) notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) resetInspectionWithCrane : (InspectionCrane *) crane  {
    _inspectionViewController.optionLocation = 0;
    [[IACraneInspectionDetailsManager sharedManager] setCrane:crane];
    [_inspectionViewController initiateParts];
}

- (IBAction)resetInspectionPressed:(id)sender {
    
    NSInteger selectedRow = [_craneDescriptionPickerView selectedRowInComponent:0];
    
    InspectionCrane *selectedCrane = [_craneDescriptionsArray objectAtIndex:selectedRow];
    
    [self resetInspectionWithCrane:selectedCrane];
    
}

- (IBAction)setCrane:(id)sender {
    
    _craneDescriptionPickerView.userInteractionEnabled = NO;
    [_craneDescriptionPickerView setAlpha:.5f];
    UIButton *button = (UIButton *) sender;
    [button setTitle:@"Change Crane" forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(setCrane:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(changeCraneType:) forControlEvents:UIControlEventTouchUpInside];
    
    isCraneSet = YES;
}

- (void) changeCraneType:(id) sender {
    _craneDescriptionPickerView.userInteractionEnabled = YES;
    [_craneDescriptionPickerView setAlpha:1.0f];
    UIButton *button = (UIButton *) sender;
    [button setTitle:@"Select Crane" forState:UIControlStateNormal];
    [button removeTarget:self action:@selector(changeCraneType:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(setCrane:) forControlEvents:UIControlEventTouchUpInside];
    
    isCraneSet = NO;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

}

- (IBAction)promptOkPressed:(id)sender {
    
}

- (IBAction)promptCancelPressed:(id)sender {
    
}

#pragma mark Picker Data Source Methods

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Reset the inspection details
    InspectionCrane *crane = [_craneDescriptionsArray objectAtIndex:row];
    [self resetInspectionWithCrane:crane];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [_craneDescriptionsArray count];
}
#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    InspectionCrane *crane = [_craneDescriptionsArray objectAtIndex:row];
    
    return crane.name;
    
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 333.0f;
}

- (IBAction)NewCustomerPress:(id)sender {
    [self EmptyTextFields];
    [_inspectionViewController setOptionLocation:0];
}
- (void) EmptyTextFields
{
    _txtCustomerName.text = @"";
    _txtAddress.text=@"";
    _txtJobNumber.text = @"";
    _txtCustomerContact.text = @"";
    _txtCap.text = @"";
    _txtCraneMfg.text = @"";
    _txtCraneSrl.text = @"";
    _txtCustomerName.text = @"";
    _txtEquipNum.text = @"";
    _txtHoistMdl.text = @"";
    _txtHoistMfg.text = @"";
    _txtHoistSrl.text = @"";
    _txtEmail.text = @"";
}

@end
