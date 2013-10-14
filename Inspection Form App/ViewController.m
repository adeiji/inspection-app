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
#import "ItemListConditionStorage.h"
#import "Condition.h"
#import "sqlite3.h"
#import "TableViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "UIKit/UIkit.h"
#import <Dropbox/Dropbox.h>
#import "OrdinalNumberFormatter.h"
#import "Foundation/NSDateFormatter.h"
#import "DataLayer.h"

@interface ViewController () {
    ItemListConditionStorage *myItemListStore; 
    DBRestClient *restClient;
    sqlite3 *contactDB;
    NSString *databasePath;
    NSString *tableName;
    NSString *part;
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
}
@end

@implementation ViewController
@synthesize txtDate;
@synthesize DefficiencyPicker;
@synthesize defficiencySwitch;
@synthesize pickerData;
@synthesize optionLocation;
@synthesize btnSelectDate;
@synthesize datePicker;
@synthesize myDatePicker;
@synthesize gestureStartPoint;
@synthesize tableViewCell;
@synthesize navBar;
@synthesize navSubmit;
@synthesize pickerDataStorage;
@synthesize tableViewCell1;
@synthesize secondViewController;
@synthesize firstViewController;
@synthesize rootViewController;
@synthesize viewAllController;
@synthesize autographController;
@synthesize navController;
@synthesize myPartsTable;
@synthesize myPartsArray;
@synthesize lblPartNumber;
@synthesize lblPart;
@synthesize partsTable;
@synthesize txtCustomerName;
@synthesize txtCustomerContact;
@synthesize txtJobNumber;
@synthesize txtAddress;
@synthesize txtEquipDesc;
@synthesize txtCraneMfg;
@synthesize txtHoistMfg;
@synthesize txtHoistMdl;
@synthesize txtCap;
@synthesize txtCraneSrl;
@synthesize txtHoistSrl;
@synthesize txtEquipNum;
@synthesize txtNotes;
@synthesize txtEmail;
@synthesize jobnumber;
@synthesize viewPDFController;
@synthesize openInButton;
@synthesize txtCraneDescription;
@synthesize txtTechnicianName;
@synthesize lblCraneDesc;
@synthesize applicableSwitch;
@synthesize CreateCertificateButton;
@synthesize CraneDescriptionUIPicker;
@synthesize customerName;
@synthesize craneDescriptionsArray;
@synthesize selectCraneButton;
@synthesize CustomerInfoView;
@synthesize CustomerInfoScrollView;
@synthesize CustomerInfoFullView;
@synthesize CraneInspectionView;
@synthesize scrollView;
@synthesize dataStore;
@synthesize table;
@synthesize account;

#define kMinimumGestureLength   25
#define kMaximumVariance        100

- (void)viewDidLoad {
    [self InitiateParts];
    changeLayoutNeeded = NO;
    iosVersion = [[UIDevice currentDevice] systemVersion];
   // CustomerInfoView.frame = CGRectMake(0, 0, 768, 1005);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    craneDescriptionsArray = [[NSMutableArray alloc] initWithObjects:@"BRIDGE", @"JIB", @"MONORAIL", @"GANTRY", nil];
    owner = @"";
    [self LoadOwner];
    if ([owner isEqual:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Name Alert" message:@"Enter your name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }
    txtCraneDescription.inputView = CraneDescriptionUIPicker;
    txtCraneDescription.inputAccessoryView = selectCraneButton;
    testLoads =  @"";
    proofLoadDescription = @"";
    loadRatingsText = @"";
    remarksLimitationsImposed = @"";
    [self.view insertSubview:CustomerInfoFullView atIndex:0];
    //CustomerInfoScrollView = CustomerInfoView;
    [self createDatabase];
    // Do any additional setup after loading the view, typically from a nib.
    NSDate *now = [NSDate date];
    myDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [myDatePicker setDate:now animated:NO];
    [myDatePicker setDatePickerMode:UIDatePickerModeDate];
    txtDate.inputView = myDatePicker; 
    txtDate.inputAccessoryView = btnSelectDate;
    navBar.topItem.title = @"Inspection Form App";
    optionLocation=0;
    overallRating = @"";
    technicianName = @"";
    txtTechnicianName.text = technicianName;
    manufacturer = @"";
    //GradientView* myView = [[GradientView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    
    [self didPressLink];
    txtTechnicianName.text = [owner uppercaseString];
    [super viewDidLoad];
}

#pragma mark - Dropbox Datastore Methods

- (void) didPressLink
{
    account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account) {
        NSLog(@"App already linked");
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}


//If there is not a Dropbox Datastore Table already created, we create it, as well as the data store.
- (void) createDatastoreTable
{
    account = [[DBAccountManager sharedManager] linkedAccount];
    dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
    table = [dataStore getTable:@"inspections"];
}


//Adds the record to the database.  Adds the record with the corresponding date, that way we can pull previous orders by date.
- (void) insertInspectionToDatastoreTable
{
    //Get all the records with this hoistSrl and this specific date
    NSDictionary *query = @{ @"hoistSrl" : txtHoistSrl.text, @"date" : txtDate.text };
    
    //Remove the records that match the specified query fromt he database
    [DataLayer removeFromDatastoreTable:query DBAccount:account DBDatastore:dataStore DBTable:table];
    
    //Go through each condition in the current inspection and then write this information to the Datastore
    for (Condition *condition in myItemListStore.myConditions)
    {
        static int i = 0;
        NSString *isDeficient = @"NO";
        NSString *isApplicable = @"NO";
        
        if (condition.deficient == YES)
        {
            isDeficient = @"YES";
        }
        if (condition.applicable == YES)
        {
            isApplicable = @"YES";
        }
        
        //inserts the current condition in the row
        pickerSelection =  [NSString stringWithFormat:@"%d", condition.pickerSelection];
        //Create the dictionary that contains all the information for this record.
        NSDictionary *conditionDictionary = [[NSDictionary alloc] initWithObjectsAndKeys
                                             :txtHoistSrl.text, @"hoistsrl",
                                             txtJobNumber.text, @"jobnumber",
                                             txtEquipNum.text, @"equipmentnumber",
                                             (NSString *)[myPartsArray objectAtIndex:i], @"part",
                                             (NSString *) isDeficient, @"deficient",
                                             condition.deficientPart, @"deficientpart",
                                             [condition.notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\\"], @"notes",
                                             pickerSelection, @"pickerselection",
                                             isApplicable, @"isapplicable",
                                             nil];
        
        //Add this condition to the datastore
        [DataLayer insertInspectionToDatastoreTable:myItemListStore.myConditions DictionaryToStore:conditionDictionary];
        i++;
    }
    //Sync the local database with the Datastore API
    [DataLayer sync : dataStore];
}


- (void)viewDidUnload
{
    [self setDefficiencySwitch:nil];
    [self setDefficiencyPicker:nil];
    [self setTxtDate:nil];
    [self setBtnSelectDate:nil];
    [self setTableViewCell:nil];
    [self setNavBar:nil];
    [self setNavSubmit:nil];
    [self setTableViewCell1:nil];
    [self setSecondViewController:nil];
    [self setFirstViewController:nil];
    [self setLblPart:nil];
    [self setLblPartNumber:nil];
    [self setPartsTable:nil];
    [self setTxtCustomerName:nil];
    [self setTxtCustomerContact:nil];
    [self setTxtJobNumber:nil];
    [self setTxtAddress:nil];
    [self setTxtEquipDesc:nil];
    [self setTxtCraneMfg:nil];
    [self setTxtHoistMfg:nil];
    [self setTxtHoistMdl:nil];
    [self setTxtCap:nil];
    [self setTxtCraneSrl:nil];
    [self setTxtHoistSrl:nil];
    [self setTxtEquipNum:nil];
    [self setTxtNotes:nil];
    [self setRootViewController:nil];
    [self setViewAllController:nil];
    [self setNavController:nil];
    [self setMyPartsTable:nil];
    [self setAutographController:nil];
    [self setViewPDFController:nil];
    [self setOpenInButton:nil];
    [self setTxtEmail:nil];
    [self setTxtCraneDescription:nil];
    [self setTxtTechnicianName:nil];
    [self setLblCraneDesc:nil];
    [self setApplicableSwitch:nil];
    myItemListStore = nil;
    restClient = nil;
    contactDB=nil;
    databasePath = nil;
    tableName = nil;
    part = nil;
    deficient = nil;
    deficientPart = nil;
    notes = nil;
    pickerSelection = nil;
    theScrollView = nil;
    activeField = nil;
    overallRating = nil;
    technicianName = nil;
    [self setCreateCertificateButton:nil];
    [self setCraneDescriptionUIPicker:nil];
    [self setSelectCraneButton:nil];
    [self setCustomerInfoView:nil];
    [self setCraneInspectionView:nil];
    [self setCustomerInfoView:nil];
    [self setCustomerInfoFullView:nil];
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.datePicker = nil;
    // Release any retained subviews of the main view.
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}
#pragma mark TextField Methods

//When you begin editing any text field this method is called in order to tell the compiler which text field is currently in focus
//so that it is known where the screen needs to scroll to, to show the text box when it is being edited
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 12)
    {
        CraneDescriptionUIPicker.hidden = FALSE;
        selectCraneButton.hidden = FALSE;
    } 
    activeField = textField;
}
//memmory management
- (void) textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 12)
    {
        CraneDescriptionUIPicker.hidden = TRUE;
    }
    activeField = nil;
}

- (void) LoadOwner
{
    owner = [DataLayer LoadOwner:databasePath contactDb:contactDB];
}
#pragma mark Database Methods


//gets customer information and crane information from the JOBS table with the specified equip # and then displays this information on the home page

- (void) LoadEquipNumPressed:(id)sender
{
    [self EmptyTextFields];
}

//Grab the crane information from the WATERDISTRICTCRANES table with the HoistSrl as the identifier and then insert the results onto the home page
//Automatically insert the customerName, customerContact, Address and Email
- (IBAction)LoadHoistSrlPressed:(id)sender {

    [self OpenOrderFromField:txtHoistSrl];
}

//this method will need to open the order by getting both the hoist srl number or equip number and the job number so that they can get any hoist srl at any time
- (void) OpenOrderFromField: (UITextField *) input;
{
    
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}
//when the back button on the viewPDFController viewController is pressed
- (IBAction)finalBackButtonPressed:(id)sender {
    [viewPDFController.view removeFromSuperview];
    [self.view insertSubview:CraneInspectionView atIndex:0];
}
//When the correct date is selected from the DatePicker then this method will convert the long date to the short date
//ex: April 12, 2012 = 4/12/12
- (IBAction)dateSelected:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString * date = [[NSString alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    date = [dateFormatter stringFromDate:myDatePicker.date];
    txtDate.text = date;
    
    [txtDate resignFirstResponder];
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


- (BOOL) shouldAutorotate
{
    return YES;
}

- (IBAction)buttonPressed {
    NSDate *myDate = [myDatePicker date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [format stringFromDate:myDate];
    NSLog (@"date: %@", dateString);
    txtDate.text = dateString;
    [myDatePicker removeFromSuperview];
    dateString = nil;
    myDate = nil;
    format = nil;
}

- (void) fillOptionArrays {
    Options* myOptions = [[Options alloc] init:txtCraneDescription.text];
    
    pickerDataStorage = myOptions.myOptionsArray;
    [self changePickerArray:pickerDataStorage];
}

- (void) changePickerArray : (NSMutableArray*) input {
    self.pickerData = nil;
    self.pickerData = [input objectAtIndex:optionLocation];
    [self.DefficiencyPicker reloadAllComponents];
}

- (IBAction)datePressed:(id)sender {
    btnSelectDate.hidden = NO;
}

//On the deficiency information pages, when you press the submit button
- (IBAction)submitPressed:(id)sender {
    //First we check to see if any of the fields in the customerInfo page and if there are any empty fields then the user is not allowed to submit the information and a UIAlertView pops
    //up telling you that there are fields where nothing was inserted into the fields
    if ([txtHoistSrl.text isEqualToString:@""] || 
        [txtTechnicianName.text isEqualToString:@""] || 
        [txtCustomerName.text isEqualToString:@""] ||
        [txtCustomerContact.text isEqualToString:@""] ||
        [txtJobNumber.text isEqualToString:@""] ||
        [txtDate.text isEqualToString:@""] ||
        [txtAddress.text isEqualToString:@""] ||
        [txtEmail.text isEqualToString:@""] ||
        [txtEquipNum.text isEqualToString:@""] ||
        [txtCraneMfg.text isEqualToString:@""] ||
        [txtHoistMfg.text isEqualToString:@""] ||
        [txtHoistMdl.text isEqualToString:@""] ||
        [txtCraneDescription.text isEqualToString:@""] ||
        [txtCraneSrl.text isEqualToString:@""] ||
        [txtCap.text isEqualToString:@""])
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"All values on the main screen must be entered!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [error show];
    } //checks to see if there are any quotation marks inside of any of the fields, and if there are any then the user is not allowed to enter the customer, and a UIAlertView pops up
    //telling you that there are fields with quotations marks inside of it
    else if ([txtHoistSrl.text rangeOfString:@"\""].location != NSNotFound || 
             [txtTechnicianName.text rangeOfString:@"\""].location != NSNotFound || 
             [txtCustomerName.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCustomerContact.text rangeOfString:@"\""].location != NSNotFound ||
             [txtJobNumber.text rangeOfString:@"\""].location != NSNotFound ||
             [txtDate.text rangeOfString:@"\""].location != NSNotFound ||
             [txtAddress.text rangeOfString:@"\""].location != NSNotFound ||
             [txtEmail.text rangeOfString:@"\""].location != NSNotFound ||
             [txtEquipNum.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [txtHoistMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [txtHoistMdl.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneDescription.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneSrl.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCap.text rangeOfString:@"\""].location != NSNotFound)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"Can not enter character 'quotation mark' ' \" ' into any field!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [error show];
    }
    else { //if all the fields entered pass then, the the customer information is inserted and all the data is saved into a table
        NSUInteger selectedRow = [DefficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[DefficiencyPicker delegate] pickerView:DefficiencyPicker titleForRow:selectedRow forComponent:0];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Overall Rating" message:@"What is the overall condition rating?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"ok", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        pageSubmitAlertView = YES;
        
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[DefficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        [self insertInspectionToDatastoreTable];    //save the current condition so that if the user goes to the next part and back, the correct information will be displayed
        [self InsertCustomerIntoTable];     //save the customer to the table
        [self InsertCraneIntoTable];        //save the crane into the table
        inspectionComplete = YES;
        myDeficientPart = nil;
        loadRatingsText = @"";
        proofLoadDescription = @"";
        testLoads = @"";
        remarksLimitationsImposed = @"";
    }
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

-(IBAction)switchView {
    [CustomerInfoFullView removeFromSuperview];
    [self.view addSubview:CraneInspectionView];
}

- (IBAction)switchChanged:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    BOOL setting = mySwitch.isOn;
    
    if (setting == TRUE) {
        DefficiencyPicker.alpha = 1;
        DefficiencyPicker.showsSelectionIndicator = YES;
        DefficiencyPicker.userInteractionEnabled = YES;

        if ([lblPart.text isEqualToString:@"Wire Rope, Load Chain, Fittings"])
        {
            timesShown=0;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Length:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
        else if ([lblPart.text isEqualToString:@"Hoist Load Brake"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Type" message:@"What is the type?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
    }
    else {
        DefficiencyPicker.alpha = .5;
        DefficiencyPicker.showsSelectionIndicator = NO;
        DefficiencyPicker.userInteractionEnabled = NO;
        }
}

//################################################################### A L E R T  V I E W  M E T H O D S ########################################################
#pragma mark - Alert View Methods
//this method handles all alert view finishes
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        if ([owner isEqual:@""])
        {
            for (UIView* view in alertView.subviews)
            {
                if ([view isKindOfClass:[UITextField class]])
                {
                    UITextField *textField = (UITextField *) view;
                    if ([textField.text isEqual:@""])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Name Alert" message:@"Enter your name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                    }
                    else
                    {
                        owner = textField.text;
                        txtTechnicianName.text = [owner uppercaseString];
                        [self InsertOwnerIntoTable:owner];
                    }
                }
            }
    }
    }
    if ((buttonIndex!=0 || loadRatings == YES || remarksLimitations == YES || finished == YES || proofLoad == YES) || (buttonIndex == 1 && testLoad == YES))
    {
        for (UIView* view in alertView.subviews)
        {
            if ([view isKindOfClass:[UITextField class]])
            {
                UITextField *textField = (UITextField*) view;
                //if this is not the alert box that opens when you submit the final page
                if (pageSubmitAlertView==NO)
                {
                    if ([lblPart.text isEqualToString:@"Control Station Markings"])
                    {
                        txtNotes.text = [NSString stringWithFormat:@"%@ %@", txtNotes.text, textField.text];
                    }
                    else if (timesShown==0&&optionLocation==22)
                    {
                        timesShown++;
                        txtNotes.text = [NSString stringWithFormat:@"Length: %@ - %@",textField.text, txtNotes.text]; 
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Size:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==1&&optionLocation==22)
                    {
                        timesShown++;
                        txtNotes.text = [NSString stringWithFormat:@"Size: %@ - %@",textField.text, txtNotes.text]; 
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Fittings:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==2&&optionLocation==22)
                    {
                        timesShown++;
                        txtNotes.text = [NSString stringWithFormat:@"Fittings: %@ - %@",textField.text, txtNotes.text]; 
                        pageSubmitAlertView = NO;
                    }
                    else if (![textField.text isEqualToString:@""])
                    {
                        txtNotes.text = [NSString stringWithFormat:@"%@ - %@",textField.text, txtNotes.text]; 
                        NSLog(@"text:[%@]", textField.text);
                        break;
                    }
                    else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must enter a value" message:@"A value must be entered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                    }
                }
                //if this is the alertbox for when you submit the form
                else {
                    //first we check to see if we are at the testLoad box
                    if (loadRatings == NO && testLoad == NO && remarksLimitations == NO && finished == NO && proofLoad == NO)
                    {
                        //check to see if this is a number
                        if ([[NSScanner scannerWithString:textField.text] scanFloat:NULL])
                        {
                            if (([textField.text intValue]<0 || [textField.text intValue]>5) && (loadRatings == NO && testLoad == NO && remarksLimitations == NO && finished == NO && proofLoad == NO))
                            {   
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Input" message:@"You must enter a number between 1 and 5" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                [alert show];
                                overallRating = @"";
                            }
                            //if this is the overall rating box and its a number between 1 and 5
                            else {
                                overallRating = textField.text;
                        
                                //convert overall rating to int and then if it's less then 3 then we ask three more questions
                                if ([overallRating intValue] < 3)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Loads?" message:@"Is This a Test Load?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
                                    [alert show];
                                    testLoad = YES;
                                    CreateCertificateButton.enabled = TRUE;
                                }
                                else {
                                    CreateCertificateButton.enabled = FALSE;
                                    [self DisplayPDFWithOverallRating];
                                }
                            }
                        }
                        else {//if the overall rating was inputed as greater then 5 or less than 1, and if it was not an integer
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Input" message:@"You must enter a number between 1 and 5" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert show];
                            overallRating = @"";
                        }
                    }
                    else {//here is where we start displaying the Alert Boxes which will ask questions about for the Certficate
                        if (proofLoad == YES)
                        {
                            testLoads = textField.text;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proof Load Description" message:@"Description of Proof Load" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                            [alert show];
                            loadRatings = YES;
                            proofLoad = NO;
                            testLoads = textField.text;
                        }
                        else if (loadRatings == YES)
                        {
                            proofLoadDescription = textField.text;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Ratings" message:@"Basis for assigned load ratings" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                            [alert show];
                            remarksLimitations = YES;
                            loadRatings = NO;
                        }
                        else if (remarksLimitations == YES)
                        {
                            loadRatingsText = textField.text;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remarks Limitations" message:@"Remarks and/or Limitations Imposed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                            [alert show];
                            remarksLimitations = NO;
                            finished = YES;
                            loadRatingsText = textField.text;
                        }
                        else if (finished == YES)
                        {
                            remarksLimitationsImposed = textField.text;
                            finished = NO;
                            [self DisplayPDFWithOverallRating];
                            [self writeCertificateTextFile];
                            CreateCertificateButton.enabled = TRUE;
                        }

                    }
                }
            }
            else {
                if (pageSubmitAlertView==YES && testLoad == YES) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applied Test Loads" message:@"Test Loads Applied" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    [alert show];
                    proofLoad = YES;
                    testLoad = NO;
                }
            }
        }
    }//if the cancel button is pressed and we are in the midst of asking the questions for the certificate
    else if (buttonIndex ==0 && testLoad == false)
    {
    }
    else
    {
        testLoad = NO;
        [self DisplayPDFWithOverallRating];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    CGRect anotherrect=[[UIApplication sharedApplication]statusBarFrame];
    
    if (changeLayoutNeeded == YES && ![iosVersion isEqualToString: @"5.1.1"])
    {
        changeLayoutNeeded = NO;
        CustomerInfoScrollView.center=CGPointMake(CustomerInfoScrollView.center.x, CustomerInfoScrollView.center.y+anotherrect.size.height); // fix silliness in IB that makes view start 20 pixels higher than it should on iPhone
        CustomerInfoScrollView.frame = CGRectMake(0, 20, 768, 1004);
        CraneInspectionView.center=CGPointMake(CraneInspectionView.center.x, CraneInspectionView.center.y+anotherrect.size.height); // fix silliness in IB that makes view start 20 pixels higher than it should on iPhone
        CraneInspectionView.frame = CGRectMake(0, 20, 768, 1004);
    }
}

-(void) DisplayPDFWithOverallRating
{
    [self writeTextFile:myItemListStore];
    //[CraneInspectionView removeFromSuperview];
    
    changeLayoutNeeded = YES;
    
    //[self.view insertSubview:viewPDFController.view atIndex:0];
    NSString *dateNoSlashes = [txtDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF",txtCustomerName.text, txtHoistSrl.text, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pdfFileName]];
    //[controller setUTI:@"PDF"];
    controller.delegate = self;
  
    [controller presentPreviewAnimated:NO];
    
    //[CraneInspectionView removeFromSuperview];
    //[self.view addSubview:self.autographController.view];
    [self writeCertificateTextFile];
}

- (IBAction)CreateCertificate:(id)sender {
    NSString *dateNoSlashes = [txtDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF",txtCustomerName.text, txtHoistSrl.text, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    secondController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pdfFileName]];
    //[controller setUTI:@"PDF"];
    secondController.delegate = self;
    CGRect navRect = self.navigationController.navigationBar.frame;
    navRect.size = CGSizeMake(1500.0f, 40.0f);
    [secondController presentPreviewAnimated:NO];
    //disable the button certificate button so that we make sure there's no errant certificates being made
    CreateCertificateButton.enabled = FALSE;
    //[CraneInspectionView removeFromSuperview];
    //[self.view addSubview:self.autographController.view];
}

- (IBAction)partsListButtonClicked:(id)sender{
    optionLocation = 0;
    Parts *parts = [[Parts alloc] init : txtCraneDescription.text];
    //myItemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];
    [lblPart awakeFromNib];
    myPartsArray = [parts myParts];
    [self fillOptionArrays];
    [self changeLayout:optionLocation];
    [self.CustomerInfoFullView removeFromSuperview];
    [self.view insertSubview:self.CraneInspectionView atIndex:0];
}

-(void) didReceiveMemoryWarning
{
    NSLog(@"Memory warning received, but ignored due to fact that this program does not consume that much memory.");
}

- (IBAction)buttonPressed:(id)sender {
}

//This method saves the information in the conditions list
- (void) saveInfo : (NSString *) myNotes
                  : (BOOL) myDeficient
                  : (NSUInteger) mySelection
                  : (NSString *) myDeficientPart
                  : (BOOL) myApplicable
{
    Condition *myCondition = [[Condition alloc] initWithParameters:myNotes :myDeficient:mySelection:myDeficientPart:myApplicable];
    [myItemListStore setCondition:optionLocation :myCondition];
    myCondition = nil;
}

- (void) changeLayout:(int) input {
    Condition *myCondition = [[Condition alloc] init ];
    myCondition = [myItemListStore.myConditions objectAtIndex:input];
    txtNotes.text = myCondition.notes;
    NSString* myPart = [myPartsArray objectAtIndex:optionLocation];
    NSString* myPartNumber = [NSString stringWithFormat:@"Part #%d", optionLocation + 1];
    [lblPart setText:myPart];
    [lblPartNumber setText:myPartNumber];
    [DefficiencyPicker selectRow:myCondition.pickerSelection inComponent:0 animated:YES];
    [defficiencySwitch setOn:myCondition.deficient];
    [applicableSwitch setOn:myCondition.applicable];
    
    if ([lblPart.text isEqualToString:@"Control Station Markings"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Additional Information" message:@"Is this a pendant or radio, and what is the manufacturer and model" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        pageSubmitAlertView = NO;
    }
    
    if (defficiencySwitch.isOn==YES) {
        DefficiencyPicker.userInteractionEnabled = YES;
        DefficiencyPicker.alpha = 1;
        DefficiencyPicker.showsSelectionIndicator = YES;
    }
    else {
        DefficiencyPicker.userInteractionEnabled = NO;
        DefficiencyPicker.showsSelectionIndicator = NO;
        DefficiencyPicker.alpha = .5;
    }
    if (applicableSwitch.on == NO)
    {
        defficiencySwitch.enabled = YES;
        txtNotes.userInteractionEnabled = YES;
        txtNotes.alpha = 1;
    }
    else {
        defficiencySwitch.enabled = NO;
        txtNotes.userInteractionEnabled = NO;
        txtNotes.alpha = .5;
    }
}
//On the customer page, submits the information into the database on the iPad
- (IBAction)CustomerSubmitPressed:(id)sender {
    if ([txtHoistSrl.text isEqualToString:@""] || 
        [txtTechnicianName.text isEqualToString:@""] || 
        [txtCustomerName.text isEqualToString:@""] ||
        [txtCustomerContact.text isEqualToString:@""] ||
        [txtJobNumber.text isEqualToString:@""] ||
        [txtDate.text isEqualToString:@""] ||
        [txtAddress.text isEqualToString:@""] ||
        [txtEmail.text isEqualToString:@""] ||
        [txtEquipNum.text isEqualToString:@""] ||
        [txtCraneMfg.text isEqualToString:@""] ||
        [txtHoistMfg.text isEqualToString:@""] ||
        [txtHoistMdl.text isEqualToString:@""] ||
        [txtCraneDescription.text isEqualToString:@""] ||
        [txtCraneSrl.text isEqualToString:@""] ||
        [txtCap.text isEqualToString:@""])
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"All values must be entered!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [error show];
    }
    else if ([txtHoistSrl.text rangeOfString:@"\""].location != NSNotFound || 
             [txtTechnicianName.text rangeOfString:@"\""].location != NSNotFound || 
             [txtCustomerName.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCustomerContact.text rangeOfString:@"\""].location != NSNotFound ||
             [txtJobNumber.text rangeOfString:@"\""].location != NSNotFound ||
             [txtDate.text rangeOfString:@"\""].location != NSNotFound ||
             [txtAddress.text rangeOfString:@"\""].location != NSNotFound ||
             [txtEmail.text rangeOfString:@"\""].location != NSNotFound ||
             [txtEquipNum.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [txtHoistMfg.text rangeOfString:@"\""].location != NSNotFound ||
             [txtHoistMdl.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneDescription.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCraneSrl.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCap.text rangeOfString:@"\""].location != NSNotFound)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"Can not enter character ' \" ' into any field!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [error show];
    }
    else 
    {
        Parts *parts = [[Parts alloc] init : txtCraneDescription.text];
        //myItemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];
        [lblPart awakeFromNib];
        myPartsArray = [parts myParts];
        [self fillOptionArrays];
        [self changeLayout:optionLocation];
        [self InsertCustomerIntoTable];
        [self.CustomerInfoFullView removeFromSuperview];
        [self.view insertSubview:self.CraneInspectionView atIndex:0];
    }
}

- (IBAction)GoHome:(id)sender
{
    [self.viewPDFController.view removeFromSuperview];
    [self.view insertSubview:self.CustomerInfoFullView atIndex:0];
}

- (IBAction)NASwitchChanged:(id)sender {
    if (applicableSwitch.on == YES)
    {
        defficiencySwitch.enabled = NO;
        DefficiencyPicker.userInteractionEnabled = NO;
        DefficiencyPicker.alpha = .5;
        DefficiencyPicker.showsSelectionIndicator = NO;
        defficiencySwitch.on = NO;
        txtNotes.userInteractionEnabled = NO;
        txtNotes.alpha = .25;
        txtNotes.text = @"";
    }
    else {
        defficiencySwitch.enabled = YES;
        txtNotes.alpha = 1;
        txtNotes.userInteractionEnabled = YES;
        if (defficiencySwitch.on == YES)
        {
            DefficiencyPicker.userInteractionEnabled = YES;
            DefficiencyPicker.alpha = 1;
            DefficiencyPicker.showsSelectionIndicator = YES;
        }
    }
}
//Inserts a customer into the dropbox datastore jobs table
- (void) InsertCustomerIntoTable
{
    
}

- (IBAction)nextPressed {
    if (optionLocation < pickerDataStorage.count - 1) {
        NSUInteger selectedRow = [DefficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[DefficiencyPicker delegate] pickerView:DefficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[DefficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        optionLocation = optionLocation + 1;
        [self changePickerArray:pickerDataStorage];
        [self changeLayout:optionLocation];
    }
}
- (IBAction)previousPressed {
    if (optionLocation > 0) {
        NSUInteger selectedRow = [DefficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[DefficiencyPicker delegate] pickerView:DefficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[DefficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        optionLocation = optionLocation - 1;
        [self changePickerArray:pickerDataStorage];
        [self changeLayout:optionLocation];
    }
}

- (void) keyboardWasShown:(NSNotification *) notification
{
    
    //Get the size of the keyboard
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
    
    //Adjust the bottom content inset of your scroll view by the keyboard height
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    CustomerInfoScrollView.contentInset = contentInsets;
    CustomerInfoScrollView.scrollIndicatorInsets = contentInsets;
    
    //scroll the target text field into view
    CGRect aRect = self.view.frame;
    aRect.size.height -=keyboardSize.height;
    
    if ([activeField isEqual:txtCap]||[activeField isEqual:txtCraneDescription]||[activeField isEqual:txtCraneMfg]||[activeField isEqual:txtCraneSrl]||
        [activeField isEqual:txtEquipNum]||[activeField isEqual:txtEquipDesc]||[activeField isEqual:txtHoistMdl])
    {
    //if (CGRectContainsPoint(aRect, activeField.frame.origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, keyboardSize.height);
        [CustomerInfoScrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void) keyboardWillBeHidden:(NSNotification *) notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    CustomerInfoScrollView.contentInset = contentInsets;
    CustomerInfoScrollView.scrollIndicatorInsets = contentInsets;
}



//-------------------------------------------------T O U C H  E V E N T S----------------------------------------------------------------------------



#pragma mark - Touch Events
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self.view];
    
    CGFloat deltaX = fabsf(gestureStartPoint.x - currentPosition.x);
    CGFloat deltaY = fabsf(gestureStartPoint.y - currentPosition.y);
    
    if (deltaX >= kMinimumGestureLength && currentPosition.x < gestureStartPoint.x && deltaY <= kMaximumVariance) {
        [self nextPressed];
    }
    else if ((deltaX >= kMinimumGestureLength) && (currentPosition.x > gestureStartPoint.x) && (deltaY <= kMaximumVariance)) {
        [self previousPressed];
        
    }
    else if (deltaY >= kMinimumGestureLength && deltaX <= kMaximumVariance) {
        //do something
    }
}




//-------------------------------------------------PICKER VIEW DELEGATE METHODS----------------------------------------------------------------------------



#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    if (pickerView.tag == 0)
        return 1;
    else {
        return 1;
    }
}
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 0 )
        return [pickerData count];
    else 
        return [craneDescriptionsArray count];
}
#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 0)
        return [pickerData objectAtIndex:row];
    else {
        return [craneDescriptionsArray objectAtIndex:row];
    }
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
        return 300.0f;
    else {
        return 333.0f;
    }
}

- (IBAction)ViewAllOrders:(id)sender {
    [self.CraneInspectionView removeFromSuperview];
    [self.view insertSubview:self.viewAllController.view atIndex:0];
}

- (IBAction)gotoCustomerInfo:(id)sender {
    NSUInteger selectedRow = [DefficiencyPicker selectedRowInComponent:0];
    NSString *myDeficientPart = [[DefficiencyPicker delegate] pickerView:DefficiencyPicker titleForRow:selectedRow forComponent:0];
    [self saveInfo:txtNotes.text :defficiencySwitch.on:[DefficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
    [self.CraneInspectionView removeFromSuperview];
    [self.view insertSubview:self.CustomerInfoFullView atIndex:0];
    
}
//Create the objects necessary to view the parts list
- (void) InitiateParts
{
    Parts *parts = [[Parts alloc] init:@"Bridge"];
    myPartsArray = [parts myParts];
    myItemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];
    optionLocation = 0;
    [self changeLayout:optionLocation];
    [self changePickerArray:pickerDataStorage];
    inspectionComplete = NO;

}

- (IBAction)NewCustomerPress:(id)sender {
    [self EmptyTextFields];
    
    [self InitiateParts];
}
- (void) EmptyTextFields
{
    txtCustomerName.text = @"";
    txtAddress.text=@"";
    txtJobNumber.text = @"";
    txtCustomerContact.text = @"";
    txtCap.text = @"";
    txtCraneMfg.text = @"";
    txtCraneSrl.text = @"";
    txtCustomerName.text = @"";
    txtEquipDesc.text = @"";
    txtEquipNum.text = @"";
    txtHoistMdl.text = @"";
    txtHoistMfg.text = @"";
    txtHoistSrl.text = @"";
    txtEmail.text = @"";
    txtCraneDescription.text = @"";
    lblCraneDesc.text = @"";
}
@end