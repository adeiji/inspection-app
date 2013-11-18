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
#import "InspectionViewController.h"
#import "InspectionBussiness.h"
#import "AppDelegate.h"
#import "InspectionManager.h"

@interface ViewController () {
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
    AppDelegate* delegate;
    NSString *deviceType;
}
@end

@implementation ViewController
@synthesize txtDate;
@synthesize optionLocation;
@synthesize datePicker;
@synthesize navSubmit;
@synthesize rootViewController;
@synthesize myPartsArray;
@synthesize navBar;
@synthesize txtCustomerName;
@synthesize txtCustomerContact;
@synthesize txtJobNumber;
@synthesize txtAddress;
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
@synthesize txtCraneDescription;
@synthesize txtTechnicianName;
@synthesize lblCraneDesc;
@synthesize CreateCertificateButton;
@synthesize CraneDescriptionUIPicker;
@synthesize customerName;
@synthesize craneDescriptionsArray;
@synthesize selectCraneButton;
@synthesize CustomerInfoScrollView;
@synthesize CraneInspectionView;
@synthesize scrollView;
@synthesize dataStore;
@synthesize table;
@synthesize account;
@synthesize craneView;
@synthesize inspectionViewController;
@synthesize btnDropboxLink;

#define kMinimumGestureLength   25
#define kMaximumVariance        100

- (void)viewDidLoad {
    
    [super viewDidLoad];
    deviceType = [UIDevice currentDevice].model;
    
    if (![deviceType isEqualToString:@"iPad"])
    {
        //Get the view that will be allow the user to enter in all the job information
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"JobInfoView" owner:self options:nil] objectAtIndex:0];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSLayoutConstraint *topSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:view
                                                                              attribute:NSLayoutAttributeTop
                                                                             multiplier:1.0f
                                                                               constant:0.0f];
        NSLayoutConstraint *leftEdgeConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:view
                                                                              attribute:NSLayoutAttributeLeft
                                                                             multiplier:1.0f
                                                                               constant:0.0f];
        [self.scrollView addConstraint:topSpaceConstraint];
        [self.scrollView addConstraint:leftEdgeConstraint];
        
        [self.scrollView setContentSize:CGSizeMake(view.frame.size.width, view.frame.size.height)];
        
        [self.scrollView addSubview:view];
    }
    
    [self editInspectionViewController];

    inspection = [[Inspection alloc] init];
    
    changeLayoutNeeded = NO;
    iosVersion = [[UIDevice currentDevice] systemVersion];
   
    //Keyboard manipulation
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    delegate = [[UIApplication sharedApplication] delegate];
    

    
    craneDescriptionsArray = delegate.craneTypes;
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
    
    [self setupTxtDate];
    [self dateSelectionChanged:datePicker];
    
    navBar.topItem.title = @"Inspection Form App";
    optionLocation=0;
    
    [self resetVariables];
    
    currentOrientation = self.interfaceOrientation;
    
    txtTechnicianName.text = [owner uppercaseString];
    
    [self setUpCraneDescriptionPicker];
    
    //[self didPressLink];
    
    [self addTargetsToTextFields];
    
    
    //If the Dropbox account is linked to this device then we remove the link to dropbox button.
    account = [[DBAccountManager sharedManager] linkedAccount];
    if (account)
    {
        //If the app is already linked to dropbox then we remove the link to dropbox button
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        [toolbarItems removeObject:btnDropboxLink];
        self.toolbarItems = toolbarItems;
    }
    
    //[self createDatastoreTable];
}

- (void) setupTxtDate
{
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btnSelectDate = [[UIButton alloc] init];
    
    [btnSelectDate addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventTouchDown];
    NSDate *now = [NSDate date];
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker setDate:now animated:NO];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(dateSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    txtDate.inputView = datePicker;
}

//Every time the date selection changes it will also change in the text box
- (void) dateSelectionChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    txtDate.text = [dateFormatter stringFromDate:[datePicker date]];
}

//When the view is loaded there are specific variables that we want to be reset to force the user to have to renter them, or to refresh.
- (void) resetVariables
{
    overallRating = @"";
    txtTechnicianName.text = technicianName;
    manufacturer = @"";
    testLoads =  @"";
    proofLoadDescription = @"";
    loadRatingsText = @"";
    remarksLimitationsImposed = @"";
}

//This UIPicker is what is used to select the crane type.  This method will set up the necessary attributes.
- (void) setUpCraneDescriptionPicker
{
    //Create the crane description picker and add it to the gradient view at the very bottom which is where we show the different potential Crane Types.
    CraneDescriptionUIPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(200, -10, 358, 100)];
    CraneDescriptionUIPicker.delegate = self;
    
    CraneDescriptionUIPicker.hidden = false;
    [CraneDescriptionUIPicker setTag:1];
    [CraneDescriptionUIPicker selectRow:1 inComponent:0 animated:YES];
    CraneDescriptionUIPicker.dataSource = self;
    [craneView addSubview:CraneDescriptionUIPicker];
}

- (void) editInspectionViewController
{
    if (![[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        inspectionViewController = [[UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inspectionViewController"];
    }
    else
    {
        inspectionViewController = [[UIStoryboard storyboardWithName:@"iPadMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inspectionViewController"];
    }
    
    inspectionViewController.optionLocation = 0;
}
//Add the targets to all our textFields
- (void) addTargetsToTextFields
{
    
    SEL selector = @selector(textFieldDidBeginEditing:);
    
    [txtCustomerName addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCustomerContact addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtJobNumber addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtAddress addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCraneMfg addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtHoistMfg addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtHoistMdl addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCap addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCraneSrl addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtHoistSrl addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtEquipNum addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtEmail addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCraneDescription addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtTechnicianName addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    
    txtCustomerName.delegate = self;
    txtCustomerContact.delegate = self;
    txtJobNumber.delegate = self;
    txtAddress.delegate = self;
    txtCraneMfg.delegate = self;
    txtHoistMfg.delegate = self;
    txtHoistMdl.delegate = self;
    txtCap.delegate = self;
    txtCraneSrl.delegate = self;
    txtHoistSrl.delegate = self;
    txtEquipNum.delegate = self;
    txtEmail.delegate = self;
    txtCraneDescription.delegate = self;
    txtTechnicianName.delegate = self;
    
    [txtCustomerName setTag:0];
    [txtCustomerContact setTag:1];
    [txtJobNumber setTag:2];
    [txtAddress setTag:3];
    [txtCraneMfg setTag:4];
    [txtHoistMfg setTag:5];
    [txtHoistMdl setTag:6];
    [txtCap setTag:7];
    [txtCraneSrl setTag:8];
    [txtHoistSrl setTag:9];
    [txtEquipNum setTag:10];
    [txtCraneDescription setTag:11];
    [txtEmail setTag:12];
    [txtNotes setTag:13];
    [txtTechnicianName setTag:14];
}

#pragma mark - Dropbox Datastore Methods

- (IBAction) didPressLink
{
    account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account) {
        NSLog(@"App already linked");
        //If the app is already linked to dropbox then we remove the link to dropbox button
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        [toolbarItems removeObject:btnDropboxLink];
        self.toolbarItems = toolbarItems;
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
        //If the app is already linked to dropbox then we remove the link to dropbox button
        NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
        [toolbarItems removeObject:btnDropboxLink];
        self.toolbarItems = toolbarItems;
    }
}


//If there is not a Dropbox Datastore Table already created, we create it, as well as the data store.
- (void) createDatastoreTable
{
    
    account = [[DBAccountManager sharedManager] linkedAccount];
    dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
    table = [dataStore getTable:@"inspections"];
    
    //Set the account and datastore objects for the singleton object
    [[InspectionManager sharedManager] setDropboxAccount:account];
    [[InspectionManager sharedManager] setDataStore:dataStore];
    [[InspectionManager sharedManager] setTable:table];
}

- (void) viewWillDisappear:(BOOL)animated
{
   // [self didPressLink];
    //[self createDatastoreTable];
}

- (void)viewDidUnload
{
    [self setTxtDate:nil];
    [self setNavBar:nil];
    [self setNavSubmit:nil];
    [self setTxtCustomerName:nil];
    [self setTxtCustomerContact:nil];
    [self setTxtJobNumber:nil];
    [self setTxtAddress:nil];
    [self setTxtCraneMfg:nil];
    [self setTxtHoistMfg:nil];
    [self setTxtHoistMdl:nil];
    [self setTxtCap:nil];
    [self setTxtCraneSrl:nil];
    [self setTxtHoistSrl:nil];
    [self setTxtEquipNum:nil];
    [self setTxtNotes:nil];
    [self setRootViewController:nil];
    [self setTxtEmail:nil];
    [self setTxtCraneDescription:nil];
    [self setTxtTechnicianName:nil];
    [self setLblCraneDesc:nil];
    myItemListStore = nil;
    restClient = nil;
    contactDB=nil;
    databasePath = nil;
    tableName = nil;
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
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.datePicker = nil;
    // Release any retained subviews of the main view.
}
#pragma mark TextField Methods

//When you begin editing any text field this method is called in order to tell the compiler which text field is currently in focus
//so that it is known where the screen needs to scroll to, to show the text box when it is being edited also so that we can set the text to all capitalized.
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 12)
    {
        CraneDescriptionUIPicker.hidden = FALSE;
        selectCraneButton.hidden = FALSE;
        
    }
    textField.text = [textField.text capitalizedString];
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
- (IBAction) LoadHoistSrlPressed : (id) sender
{
    NSDictionary *query = [[NSDictionary alloc] initWithObjectsAndKeys:@"hoistsrl", txtHoistSrl.text, nil];
    
    inspection.itemList.myConditions = [[NSMutableArray alloc] initWithArray:[InspectionBussiness getRecords:query DBAccount:account DBDatastore:dataStore DBTable:table]];
    
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
    date = [dateFormatter stringFromDate:datePicker.date];
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


- (IBAction)buttonPressed {
    NSDate *myDate = [datePicker date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [format stringFromDate:myDate];
    NSLog (@"date: %@", dateString);
    txtDate.text = dateString;
    [datePicker removeFromSuperview];
    dateString = nil;
    myDate = nil;
    format = nil;
}

- (IBAction)datePressed:(id)sender {
    //btnSelectDate.hidden = NO;
}

- (ValidationResults) validateSubmission : (BOOL) showResults
{
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
        [txtCraneSrl.text isEqualToString:@""] ||
        [txtCap.text isEqualToString:@""])
    {
        if (showResults)
            
        return EMPTY_FIELD;
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
             [txtCraneSrl.text rangeOfString:@"\""].location != NSNotFound ||
             [txtCap.text rangeOfString:@"\""].location != NSNotFound)
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
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"All values on the main screen must be entered!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [error show];
    } //checks to see if there are any quotation marks inside of any of the fields, and if there are any then the user is not allowed to enter the customer, and a UIAlertView pops up telling you this
    else if (results == INVALID_CHARACTER)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Customer Error" message:@"Can not enter character 'quotation mark' ' \" ' into any field!" 
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [error show];
    }
}



//Create the crane from the info that has been inserted into the text boxes.  This crane will then be passed to the InspectionViewController.
- (Crane *) createCrane
{
    Crane *crane = [[Crane alloc] init];
    
    crane.hoistSrl = txtHoistSrl.text;
    crane.equipmentNumber = txtEquipNum.text;
    crane.description = txtCraneDescription.text;
    crane.capacity = txtCap.text;
    crane.craneSrl = txtCraneSrl.text;
    crane.hoistMdl = txtHoistMdl.text;
    crane.hoistMfg = txtHoistMfg.text;
    crane.mfg = txtCraneMfg.text;
    
    return crane;
}
//Create the customer from the info that has been inserted into the text boxes.  This customer will then be passed to the InspectionViewController.
- (Customer*) createCustomer
{
    Customer *customer = [[Customer alloc] init];
    
    customer.name = txtCustomerName.text;
    customer.contact = txtCustomerContact.text;
    customer.address = txtAddress.text;
    customer.email = txtEmail.text;
    
    return customer;
}
//Create the inspection that will be read from.
- (void) createInspection : (Crane *) crane
                 Customer : (Customer *) customer
{
    inspection = [[Inspection alloc] init];
    
    inspection.technicianName = txtTechnicianName.text;
    inspection.date = txtDate.text;
    inspection.jobNumber = txtJobNumber.text;
    inspection.crane = crane;
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
}
-(IBAction)switchView {
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

- (IBAction)partsListButtonClicked:(id)sender{

    optionLocation = 0;
    NSUInteger selectedRow = [CraneDescriptionUIPicker selectedRowInComponent:0];

    NSString * craneType = [[CraneDescriptionUIPicker delegate] pickerView:CraneDescriptionUIPicker titleForRow:selectedRow forComponent:0];
    Parts *parts = [[Parts alloc] init : craneType ];
    
    //Gets all the parts that have to do with this specific crane
    myPartsArray = [parts myParts];
    
    //Here we create all the necessary objects to store the customer and the crane information so that this can be saved to a singleton object and accessed from anywhere.
    Customer *customer = [InspectionBussiness createCustomer:txtCustomerName.text CustomerContact:txtCustomerContact.text CustomerAddress:txtAddress.text CustomerEmail:txtEmail.text];
    
    Crane *crane = [InspectionBussiness createCrane:txtHoistSrl.text CraneType:craneType EquipmentNumber:txtEquipNum.text CraneMfg:txtCraneMfg.text hoistMfg:txtHoistMfg.text CraneSrl:txtCraneSrl.text Capacity:txtCap.text HoistMdl:txtHoistMdl.text];
    
    inspection.crane = crane;
    inspection.customer = customer;
    
    inspection.jobNumber = txtJobNumber.text;
    inspection.date = txtDate.text;
    inspection.technicianName = txtTechnicianName.text;
    
    inspectionViewController.craneType = inspection.crane.type;
    inspectionViewController.partsArray = myPartsArray;
    
    //Set the objects on the singleton object
    [[InspectionManager sharedManager] setCrane:crane];
    [[InspectionManager sharedManager] setCustomer:customer];
    [[InspectionManager sharedManager] setInspection:inspection];
    
    [self.navigationController pushViewController:inspectionViewController animated:YES];
    
    //Send out a notification that the InspectionViewController is pushed onto the stack.
    //Send the crane type that is being pushed.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InspectionViewControllerPushed"
                                                        object:self
                                                      userInfo:@{@"craneType": inspectionViewController.craneType }];
//
//    //We get the first part from the dictionary that stores all the parts of the specific crane types.
//    NSString *part = [delegate.partsDictionary objectForKey:inspection.crane.type][0];
//    
//    //Send the current part so that we can fill the options array with the correct part.
//    [inspectionViewController fillOptionArrays:part];
//    [inspectionViewController changeLayout:optionLocation PartsArray:myPartsArray ItemListStore:myItemListStore];
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
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:txtCustomerName.text, @"customerName",
                                txtAddress.text, @"address",
                                txtCustomerContact.text, @"customercontact",
                                txtCustomerName.text, @"customername",
                                txtEmail.text, @"email", nil];
    
    return dictionary;
}

- (NSDictionary *) createCraneDictinoary
{
    //Get the crane type fromt he UIPicker
    NSUInteger selectedRow = [CraneDescriptionUIPicker selectedRowInComponent:0];
    NSString * craneType = [[CraneDescriptionUIPicker delegate] pickerView:CraneDescriptionUIPicker titleForRow:selectedRow forComponent:0];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                txtCap.text, @"capacity",
                                craneType, @"cranetype",
                                txtCraneMfg.text, @"cranemfg",
                                txtCraneSrl.text, @"cranesrl",
                                txtEquipNum.text, @"equipmentnumber",
                                txtHoistMdl.text, @"hoistmdl",
                                txtHoistMfg.text, @"hoistmfg",
                                txtHoistSrl.text, @"hoistsrl", nil];
    
    return dictionary;
}

//On the customer page, submits the information into the database on the iPad
- (IBAction)CustomerSubmitPressed:(id)sender {
    if ([self validateSubmission : YES] != EMPTY_FIELD || INVALID_CHARACTER)
    {
        //Get the selected crane type fromt he crane picker.
        NSUInteger selectedRow = [CraneDescriptionUIPicker selectedRowInComponent:0];

        NSString * craneType = [[CraneDescriptionUIPicker delegate] pickerView:CraneDescriptionUIPicker titleForRow:selectedRow forComponent:0];
        
        inspection.crane.description = craneType;
        
        //Gets the parts array, with the crane type changed to a normal NSString
        parts = [[Parts alloc] init : craneType];

        myPartsArray = [parts myParts];
        
        //Insert the customer info into the customer table
        dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
        table = [dataStore getTable:@"customer"];
        [InspectionBussiness insertToDatastoreTable:account DataStore:dataStore Table:table TableName:@"customer" DictionaryToAdd:[self createCustomerDictionary]];
        
        //Insert the crane info into the crane table
        table = [dataStore getTable:@"crane"];
        [InspectionBussiness insertToDatastoreTable:account DataStore:dataStore Table:table TableName:@"crane" DictionaryToAdd:[self createCraneDictinoary]];
        
        Customer *customer = [InspectionBussiness createCustomer:txtCustomerName.text CustomerContact:txtCustomerContact.text CustomerAddress:txtAddress.text CustomerEmail:txtEmail.text];
        
        Crane *crane = [InspectionBussiness createCrane:txtHoistSrl.text CraneType:craneType EquipmentNumber:txtEquipNum.text CraneMfg:txtCraneMfg.text hoistMfg:txtHoistMfg.text CraneSrl:txtCraneSrl.text Capacity:txtCap.text HoistMdl:txtHoistMdl.text];
        
        inspection.crane = crane;
        inspection.customer = customer;
        
        inspection.jobNumber = txtJobNumber.text;
        inspection.date = txtDate.text;
        inspection.technicianName = txtTechnicianName.text;
        
        inspectionViewController.craneType = inspection.crane.type;
        inspectionViewController.partsArray = myPartsArray;
        
        inspectionViewController.validated = YES;
        
        //Set the objects on the singleton object
        [[InspectionManager sharedManager] setCrane:crane];
        [[InspectionManager sharedManager] setCustomer:customer];
        [[InspectionManager sharedManager] setInspection:inspection];
        
        [self.navigationController pushViewController:inspectionViewController animated:YES];
        
        NSString *part = [delegate.partsDictionary objectForKey:inspection.crane.type][0];
        
        [inspectionViewController fillOptionArrays:part];
        [inspectionViewController changeLayout:optionLocation PartsArray:myPartsArray ItemListStore:myItemListStore];
        
        [dataStore sync:nil];
    }
    else
    {
        //Display that the user needs to change some information on the Customer Submit page in order to submit this page.
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Errors on Page" message:@"There is an error on the customer page.  Can not submit." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [view show];
    }
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self changeOrientation];
}

-(void) changeOrientation
{
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    currentOrientation = orientation;
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
    
    if ((currentOrientation==UIInterfaceOrientationLandscapeLeft) ||
        (currentOrientation==UIInterfaceOrientationLandscapeRight))
    {
        //Adjust the bottom content inset of your scroll view by the keyboard height
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.width, 0.0);
        
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        aRect.size.height -=keyboardSize.width;
        if (!CGRectContainsPoint(aRect, activeField.superview.frame.origin)) {
            CGPoint scrollPoint = CGPointMake(0.0, keyboardSize.width + activeField.superview.frame.size.height);
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
    else if ((currentOrientation==UIInterfaceOrientationPortrait) ||
             (currentOrientation==UIInterfaceOrientationPortraitUpsideDown))
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
        
        aRect.size.height -=keyboardSize.height;
        if (!CGRectContainsPoint(aRect, activeField.superview.frame.origin)) {
            CGPoint scrollPoint = CGPointMake(0.0, keyboardSize.height);
            [scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}
- (void) keyboardWillBeHidden:(NSNotification *) notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    CustomerInfoScrollView.contentInset = contentInsets;
    CustomerInfoScrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [craneDescriptionsArray count];
}
#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [craneDescriptionsArray objectAtIndex:row];
    
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 333.0f;
}

- (IBAction)NewCustomerPress:(id)sender {
    [self EmptyTextFields];
    
    [inspectionViewController initiateParts];
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
    txtEquipNum.text = @"";
    txtHoistMdl.text = @"";
    txtHoistMfg.text = @"";
    txtHoistSrl.text = @"";
    txtEmail.text = @"";
    txtCraneDescription.text = @"";
    lblCraneDesc.text = @"";
}

@end