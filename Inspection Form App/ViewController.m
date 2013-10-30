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
#import "PDFGenerator.h"
#import "InspectionViewController.h"
#import "InspectionBussiness.h"

@interface ViewController () {
    ItemListConditionStorage *myItemListStore; 
    DBRestClient *restClient;
    Parts* parts;
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
    Inspection *inspection;
    int currentOrientation;
}
@end

@implementation ViewController
@synthesize txtDate;
@synthesize optionLocation;
@synthesize btnSelectDate;
@synthesize datePicker;
@synthesize myDatePicker;
@synthesize navSubmit;
@synthesize rootViewController;
@synthesize myPartsArray;
@synthesize navBar;
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
@synthesize txtCraneDescription;
@synthesize txtTechnicianName;
@synthesize lblCraneDesc;
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
@synthesize craneView;
@synthesize inspectionViewController;

#define kMinimumGestureLength   25
#define kMaximumVariance        100

- (void)viewDidLoad {
    inspectionViewController = [[UIStoryboard storyboardWithName:@"iPadMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"inspectionViewController"];
    
    [inspectionViewController initiateParts];
    
    inspection = [[Inspection alloc] init];
    
    changeLayoutNeeded = NO;
    iosVersion = [[UIDevice currentDevice] systemVersion];
   // CustomerInfoView.frame = CGRectMake(0, 0, 768, 1005);
    //Keyboard manipulation
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
    currentOrientation = self.interfaceOrientation;
    [self didPressLink];
    txtTechnicianName.text = [owner uppercaseString];
    
    CraneDescriptionUIPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(200, -10, 358, 100)];
    CraneDescriptionUIPicker.delegate = self;
    
    CraneDescriptionUIPicker.hidden = false;
    [CraneDescriptionUIPicker setTag:1];
    [CraneDescriptionUIPicker selectRow:1 inComponent:0 animated:YES];
    CraneDescriptionUIPicker.dataSource = self;
    [craneView addSubview:CraneDescriptionUIPicker];
    
    [self addTargetsToTextFields];
    
    [super viewDidLoad];
}


//Add the targets to all our textFields
- (void) addTargetsToTextFields
{
    
    SEL selector = @selector(textFieldDidBeginEditing:);
    
    [txtCustomerName addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtCustomerContact addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtJobNumber addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtAddress addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
    [txtEquipDesc addTarget:self action:selector forControlEvents:UIControlEventEditingDidBegin];
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
    
    [txtCustomerName setTag:0];
    [txtCustomerContact setTag:1];
    [txtJobNumber setTag:2];
    [txtAddress setTag:3];
    [txtEquipDesc setTag:4];
    [txtCraneMfg setTag:5];
    [txtHoistMfg setTag:6];
    [txtHoistMdl setTag:7];
    [txtCap setTag:8];
    [txtCraneSrl setTag:9];
    [txtHoistSrl setTag:10];
    [txtEquipNum setTag:11];
    [txtCraneDescription setTag:12];
    [txtEmail setTag:13];
    [txtNotes setTag:14];
    [txtTechnicianName setTag:15];
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

- (void)viewDidUnload
{
    [self setTxtDate:nil];
    [self setBtnSelectDate:nil];
    [self setNavBar:nil];
    [self setNavSubmit:nil];
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
    [self setTxtEmail:nil];
    [self setTxtCraneDescription:nil];
    [self setTxtTechnicianName:nil];
    [self setLblCraneDesc:nil];
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

- (IBAction)datePressed:(id)sender {
    btnSelectDate.hidden = NO;
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



- (void) saveInspectionToDatabase
{
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
                                             :inspection.crane.hoistSrl, @"hoistsrl",
                                             inspection.jobNumber, @"jobnumber",
                                             inspection.crane.equipmentNumber, @"equipmentnumber",
                                             (NSString *)[myPartsArray objectAtIndex:i], @"part",
                                             (NSString *) isDeficient, @"deficient",
                                             condition.deficientPart, @"deficientpart",
                                             [condition.notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\\"], @"notes",
                                             pickerSelection, @"pickerselection",
                                             isApplicable, @"isapplicable",
                                             nil];
        
        
        //Add this condition to the datastore
        //Insert the inspection into the Dropbox Datastore
        [InspectionBussiness insertToDatastoreTable:account DataStore:dataStore Table:table TableName:@"inspections" DictionaryToAdd:conditionDictionary];
        
        i++;
    }
}

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

- (Customer*) createCustomer
{
    Customer *customer = [[Customer alloc] init];
    
    customer.name = txtCustomerName.text;
    customer.contact = txtCustomerContact.text;
    customer.address = txtAddress.text;
    customer.email = txtEmail.text;
    
    return customer;
}
//Create the inspection that will be read from
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
    [CustomerInfoFullView removeFromSuperview];
    [self.view addSubview:CraneInspectionView];
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
    
    Customer *customer = [InspectionBussiness createCustomer:txtCustomerName.text CustomerContact:txtCustomerContact.text CustomerAddress:txtAddress.text CustomerEmail:txtEmail.text];
    
    Crane *crane = [InspectionBussiness createCrane:txtHoistSrl.text CraneType:craneType EquipmentNumber:txtEquipNum.text CraneMfg:txtCraneMfg.text hoistMfg:txtHoistMfg.text CraneSrl:txtCraneSrl.text Capacity:txtCap.text HoistMdl:txtHoistMdl.text];
    
    inspection.crane = crane;
    inspection.customer = customer;
    
    inspection.jobNumber = txtJobNumber.text;
    inspection.date = txtDate.text;
    inspection.technicianName = txtTechnicianName.text;
    
    [self.navigationController pushViewController:inspectionViewController animated:YES];

    [inspectionViewController fillOptionArrays:inspection.crane.description];
    [inspectionViewController changeLayout:optionLocation PartsArray:myPartsArray ItemListStore:myItemListStore];
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
        
        //Call the parts array, with the crane type changed to a normal NSString
        parts = [[Parts alloc] init : craneType];

        myPartsArray = [parts myParts];
        
        //Insert the customer info into the customer table
        dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
        table = [dataStore getTable:@"customer"];
        [InspectionBussiness insertToDatastoreTable:account DataStore:dataStore Table:table TableName:@"customer" DictionaryToAdd:[self createCustomerDictionary]];
        
        //Insert the crane info into the crane table
        table = [dataStore getTable:@"crane"];
        [InspectionBussiness insertToDatastoreTable:account DataStore:dataStore Table:table TableName:@"crane" DictionaryToAdd:[self createCraneDictinoary]];
        
        [self.navigationController pushViewController:inspectionViewController animated:YES];
        
        [inspectionViewController fillOptionArrays:inspection.crane.description];
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