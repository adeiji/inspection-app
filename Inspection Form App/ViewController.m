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
#import "DropboxSDK/DropboxSDK.h"
#import "OrdinalNumberFormatter.h"
#import "Foundation/NSDateFormatter.h"

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

#define kMinimumGestureLength   25
#define kMaximumVariance        100

- (void)viewDidLoad {
    [self InitiateParts];
    
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
- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
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
    sqlite3_stmt *statement;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    documentsDir = [paths objectAtIndex:0];
    
    //full file location string
    databasePath = [[NSString alloc] initWithString:[documentsDir stringByAppendingPathComponent:@"contacts.db"]];
    const char *dbPath = [databasePath UTF8String];
    bool orderExist = NO;
    owner = @"";
    if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
    {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT NAME FROM IPADOWNER"];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                orderExist = YES;
                const char *chName = (char*) sqlite3_column_text(statement, 0);
                owner = [NSString stringWithUTF8String:chName];
               
                NSLog(@"Retrieved condition from the table");
                //release memory
                chName = nil;
            }
        }
        else {
            NSLog(@"Failed to find jobnumber in table");
        }
    }
}
#pragma mark Database Methods
//create the database by first creating a directory for the database to be stored to, with a name of contacts.db
- (void) createDatabase
{
    //get the path where to hold the database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    documentsDir = [paths objectAtIndex:0];

    //full file location string
    databasePath = [[NSString alloc] initWithString:[documentsDir stringByAppendingPathComponent:@"contacts.db"]];

    //make sure that this is uncommented-----------------------------****************________------------
    //databasePath = @"/Users/Developer/Documents/contacts.db";
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
        {
            sqlite3_close(contactDB);
            
        } else {
            NSLog(@"Failed to create the database");
            //txtDate.text = @"Failed to open/create database";
        }
    }
    [self createTable];
    //release memory
    paths = nil;
    documentsDir = nil;
    fileMgr = nil;
}
//create three SQL_LITE tables, ALLORDERS, JOBS, and CRANES_DONE
- (void) createTable {
    
    NSString *querySql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS ALLORDERS (ID INTEGER PRIMARY KEY AUTOINCREMENT, HOISTSRL TEXT, JOBNUMBER TEXT, EQUIPNUM TEXT, PART TEXT, DEFICIENT TEXT, DEFICIENTPART TEXT, NOTES TEXT, PICKERSELECTION TEXT, APPLICABLE TEXT)"];
    const char *sql_stmt = [querySql UTF8String];
    char *errMess;
    
    //open the database
    if (sqlite3_open([databasePath UTF8String], &contactDB) == SQLITE_OK)
    {
        //creates the table using the querySql NSString
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMess) == SQLITE_OK) 
        {
            NSLog(@"ALL ORDERS TABLE CREATED");
        }
        //query to create the JOBS table
        querySql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS JOBS (ID INTEGER PRIMARY KEY AUTOINCREMENT, HOISTSRL TEXT, CUSTOMERNAME TEXT, CONTACT TEXT, JOBNUMBER TEXT, DATE TEXT, ADDRESS TEXT, EMAIL TEXT, EQUIPNUM TEXT, CRANEMFG TEXT, HOISTMFG TEXT, HOISTMDL TEXT, CRANEDESCRIPTION TEXT, CAP TEXT, CRANESRL TEXT)"];
        sql_stmt = [querySql UTF8String];
        
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMess) == SQLITE_OK) 
        {
            NSLog(@"JOBS Table Created");
        }
        //query to create the CRANES_DONE table
        querySql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS CRANES_DONE (HOISTSRL TEXT, CUSTOMERNAME TEXT, DATE TEXT)"];
        sql_stmt = [querySql UTF8String];
        
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMess) == SQLITE_OK) 
        {
            NSLog(@"CRANES Table Created");
        }
        
        querySql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS IPADOWNER (NAME TEXT)"];
        sql_stmt = [querySql UTF8String];
        
        if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMess) == SQLITE_OK)
        {
            NSLog(@"Name Table Created");
        }
        sqlite3_close(contactDB);
    }
    //release memory
    querySql = nil;
    sql_stmt = nil;
    errMess = nil;
}

#pragma mark Dropbox Methods

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (DBRestClient *) restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void) UploadCSVFileToDropbox: (NSString *) fullPath
{
    //gets the location of the CSV file
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //create NSString object, that holds our exact path to the documents directory
    //NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", [paths objectAtIndex:0]];
    //NSString *localPath = [[NSBundle mainBundle] pathForResource:@"JonnyCranes" ofType:@"csv"];
    NSString *filename = [NSString stringWithFormat:@"%@Cranes.csv", owner];
    NSString *destDir = @"/";
    //makes sure that when the file is uploaded to the Dropbox server the existing file is overwritten, in order to make it so that the file is not overriden the code should look like this
    /*
     [[self restClient] uploadFile:filename toPath:destDir
     parentRev:nil fromPath:fullPath];
     */
    
    [[self restClient] uploadFile:filename toPath:destDir
                    fromPath:fullPath];
    
    //[[self restClient] loadMetadata:@"/"];
    filename = nil;
    destDir = nil;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"\t%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}
//Loads the entire inspection and the customer information from the JobNumber
- (IBAction)GetOrderFromJobNumber:(id)sender
{
    //get inspection from job number
    //[self OpenOrderFromJobNumber];
    //opens the customer information from the job number
    [self GetCustomerFromJobNumber];
    
}
//this method gets all customer information and crane information from the JOBS table with the specified jobnumber and displays the information on the home page
- (void) GetCustomerFromJobNumber
{/*
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    bool orderExist = NO;
    
    if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
    { 
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT JOBNUMBER, CUSTOMERNAME, CONTACT, DATE, ADDRESS, EMAIL, EQUIPNUM, CRANEMFG, HOISTMFG, HOISTMDL, CRANEDESCRIPTION, CAP, CRANESRL FROM JOBS WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                orderExist = YES;
                const char *hoistSrl = (char*) sqlite3_column_text(statement, 0);
                const char *custName = (char*) sqlite3_column_text(statement, 1);
                const char *contact = (char*) sqlite3_column_text(statement, 2);
                const char *date = (char*) sqlite3_column_text(statement, 3);
                const char *address = (char*) sqlite3_column_text(statement, 4);
                const char *email = (char*) sqlite3_column_text(statement, 5);
                const char *equipNum = (char*) sqlite3_column_text(statement, 6);
                const char *craneMfg = (char*) sqlite3_column_text(statement, 7);
                const char *hoistMfg = (char*) sqlite3_column_text(statement, 8);
                const char *hoistMdl = (char*) sqlite3_column_text(statement, 9);
                const char *craneDescription = (char*) sqlite3_column_text(statement, 10);
                const char *cap = (char*) sqlite3_column_text(statement, 11);
                const char *craneSrl = (char*) sqlite3_column_text(statement, 12);
                //makes sure that the job number stays displayed
                NSString *jobNumber = txtJobNumber.text;
                [self EmptyTextFields];
                txtJobNumber.text = jobNumber;
                
                txtHoistSrl.text = [NSString stringWithUTF8String:hoistSrl];
                txtCustomerName.text = [NSString stringWithUTF8String:custName];
                txtCustomerContact.text = [NSString stringWithUTF8String:contact];
                txtDate.text = [NSString stringWithUTF8String:date];
                txtAddress.text = [NSString stringWithUTF8String:address];
                txtEmail.text = [NSString stringWithUTF8String:email];
                txtEquipNum.text = [NSString stringWithUTF8String:equipNum];
                txtCraneMfg.text = [NSString stringWithUTF8String:craneMfg];
                txtHoistMfg.text = [NSString stringWithUTF8String:hoistMfg];
                txtHoistMdl.text = [NSString stringWithUTF8String:hoistMdl];
                txtCraneDescription.text = [NSString stringWithUTF8String:craneDescription];
                txtCap.text = [NSString stringWithUTF8String:cap];
                txtCraneSrl.text = [NSString stringWithUTF8String:craneSrl];
                lblCraneDesc.text = [NSString stringWithUTF8String:craneDescription];
                
                NSLog(@"Retrieved condition from the table");
            }
               //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Did retrieve succesfully" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"ok", nil];
               //[alert show];
        }
        else {
            NSLog(@"Failed to find jobnumber in table");
        }
    }
*/
}
//Create a CSV file from the CRANES_DONE table and then uploads file to Dropbox


- (IBAction)SelectCraneDescriptionPressed:(id)sender {
    NSUInteger selectedRow = [CraneDescriptionUIPicker selectedRowInComponent:0];
    NSString *myCraneDescription = [[CraneDescriptionUIPicker delegate] pickerView:CraneDescriptionUIPicker titleForRow:selectedRow forComponent:0];

    txtCraneDescription.text = myCraneDescription;
    selectCraneButton.hidden = TRUE;
    [self textFieldDidEndEditing:activeField];
    [CraneDescriptionUIPicker removeFromSuperview];
    [txtCraneDescription resignFirstResponder];
    [self keyboardWillBeHidden:UIKeyboardWillHideNotification];
}

- (IBAction)UpdateButtonPressed:(id)sender {
    [self SendTablesToServer];
}
//gets customer information and crane information from the JOBS table with the specified equip # and then displays this information on the home page
- (IBAction)LoadEquipNumPressed:(id)sender
{
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    bool craneExist=NO;
    
        if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
        { 
            //grab only the crane information from the WATERDISTRICTCRANES table, which simply contains the water district cranes
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT TYPE, CAPACITY, MDL_HOIST, SRL_CRANE_MFG, MANUFACTURER, SRL_HOIST FROM WATERDISTRICTCRANES WHERE UNIT_ID=\"%@\"",txtEquipNum.text];   
            const char *select_stmt = [selectSQL UTF8String];
            if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    craneExist = YES;
                    const char *type = (char*) sqlite3_column_text(statement, 0);           //information at first column
                    const char *capacity = (char*) sqlite3_column_text(statement, 1);       //second column
                    const char *mdlHoist = (char*) sqlite3_column_text(statement, 2);       //third column
                    const char *srlCraneMfg = (char*) sqlite3_column_text(statement, 3);    //fourth column
                    const char *hoistSrl = (char*) sqlite3_column_text(statement, 5);
                    //const char *manufacturer = (char*) sqlite3_column_text(statement, 4);
                    
                    NSString *equipNum = txtEquipNum.text;
                    
                    [self EmptyTextFields];
                    
                    txtHoistSrl.text = [NSString stringWithUTF8String:hoistSrl];
                    txtEquipNum.text = equipNum;
                    
                    //-----------------------Water district information -----------------
                    txtCustomerName.text = @"LVVWD";
                    txtCustomerContact.text = @"DAVID BOURN";
                    txtAddress.text = @"1001 S VALLEY VIEW BLVD, LAS VEGAS, NV 89107";
                    txtEmail.text = @"DAVID.BOURN@LVVWD.COM";
                    //txtCustomerName.text = custName;
                    //txtCustomerName.text = [NSString stringWithUTF8String:manufacturer];
                    
                    txtCraneDescription.text = [NSString stringWithUTF8String:type];    //store type
                    txtCap.text = [NSString stringWithUTF8String:capacity];             //store cap
                    txtHoistMdl.text = [NSString stringWithUTF8String:mdlHoist];        //store hoistMdl
                    txtCraneSrl.text = [NSString stringWithUTF8String:srlCraneMfg];     //store CraneSrl
                    lblCraneDesc.text = [NSString stringWithUTF8String:type];           //store CraneDesc
                    txtHoistSrl.text = [NSString stringWithUTF8String:hoistSrl];
                    
                    NSLog(@"Retrieved condition from the table");
                    //release memory
                    type = nil;
                    capacity = nil;
                    mdlHoist = nil;
                    srlCraneMfg = nil;
                    hoistSrl = nil;
                    equipNum= nil;
                }

            }
            else {
                NSLog(@"Failed to find jobnumber in table");
            }
            selectSQL = [NSString stringWithFormat:@"SELECT HOISTSRL, CUSTOMERNAME, CONTACT, DATE, ADDRESS, EMAIL, EQUIPNUM, CRANEMFG, HOISTMFG, HOISTMDL, CRANEDESCRIPTION, CAP, CRANESRL, JOBNUMBER FROM JOBS WHERE EQUIPNUM=\"%@\"", txtEquipNum.text];
            select_stmt = [selectSQL UTF8String];
            if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    craneExist = YES;
                    const char *hoistSrl = (char*) sqlite3_column_text(statement, 0);
                    const char *custName = (char*) sqlite3_column_text(statement, 1);
                    const char *contact = (char*) sqlite3_column_text(statement, 2);
                    const char *date = (char*) sqlite3_column_text(statement, 3);
                    const char *address = (char*) sqlite3_column_text(statement, 4);
                    const char *email = (char*) sqlite3_column_text(statement, 5);
                    //const char *equipNum = (char*) sqlite3_column_text(statement, 6);
                    const char *craneMfg = (char*) sqlite3_column_text(statement, 7);
                    const char *hoistMfg = (char*) sqlite3_column_text(statement, 8);
                    const char *hoistMdl = (char*) sqlite3_column_text(statement, 9);
                    const char *craneDescription = (char*) sqlite3_column_text(statement, 10);
                    const char *cap = (char*) sqlite3_column_text(statement, 11);
                    const char *craneSrl = (char*) sqlite3_column_text(statement, 12);
                    const char *chJobNumber = (char*) sqlite3_column_text(statement, 13);
                    
                    //-------------------------Customer Information-------------------------
                    //These methods call the CheckForExistingRecord method which will check to see if there is any strings within these text fields
                    //If there are none that means that the crane did not exist within the WATERCRANESDONE table, so you will then check to see if there are any cranes
                    //inside of the job table with this information, if yes, then insert that information into the tables
                    txtHoistSrl.text = [self CheckForExistingRecord:txtHoistSrl.text :hoistSrl];
                    txtCustomerName.text= [self CheckForExistingRecord:txtCustomerName.text :custName];
                    txtCustomerContact.text = [self CheckForExistingRecord:txtCustomerContact.text :contact];
                    txtDate.text = [self CheckForExistingRecord:txtDate.text :date];
                    txtAddress.text = [self CheckForExistingRecord:txtAddress.text :address];
                    txtEmail.text = [self CheckForExistingRecord:txtEmail.text :email];
                    //-----------------------Crane Information-----------------------------
                    txtCraneMfg.text = [self CheckForExistingRecord:txtCraneMfg.text :craneMfg];
                    txtHoistMfg.text = [self CheckForExistingRecord:txtHoistMfg.text :hoistMfg];
                    txtHoistMdl.text = [self CheckForExistingRecord:txtHoistMdl.text :hoistMdl];
                    txtCraneDescription.text = [self CheckForExistingRecord:txtCraneDescription.text :craneDescription];
                    txtCap.text = [self CheckForExistingRecord:txtCap.text :cap];
                    txtCraneSrl.text = [self CheckForExistingRecord:txtCraneSrl.text :craneSrl];
                    txtJobNumber.text = [self CheckForExistingRecord:txtJobNumber.text :chJobNumber];
                    lblCraneDesc.text = [self CheckForExistingRecord:txtCraneDescription.text :craneDescription];
                    
                    NSLog(@"Retrieved condition from the table");
                    //release memory
                    hoistSrl = nil;
                    custName = nil;
                    contact = nil;
                    date = nil;
                    address = nil;
                    email = nil;
                    craneMfg = nil;
                    hoistMfg = nil;
                    hoistMdl = nil;
                    craneDescription = nil;
                    cap = nil;
                    craneSrl = nil;
                    chJobNumber = nil;
                }
            }
            else {
                NSLog(@"Failed to find jobnumber in table");
            }
            //if this crane does not exist, which means that it is not a water district crane then display that it does not exist
            if (craneExist ==NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO CRANE" message:@"No CRANE by this EQUIPMENT NUMBER was found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK"    , nil];
                [alert show];
            }
            else {
                myItemListStore = [[ItemListConditionStorage alloc] init:myPartsArray];
                optionLocation = 0;
                [self changeLayout:optionLocation];
            }
            
    }
[self OpenOrderFromField:txtEquipNum];
}
//Gets a text field and checks to see whether or not it is empty, if it is empty then it returns a string which contains the correct information from the database
//if it is not empty then it keeps the string as is
- (NSString *) CheckForExistingRecord:(NSString *) textField: (const char *) input
{
    NSString *string = [NSString stringWithUTF8String:input];
    
    if ([textField isEqualToString:@""])
    {
        return string;
    }
    else {
        return textField;
    }
    return nil;
}

//creates a csv file and then uploadas that csv file to the server
- (void) SendTablesToServer
{
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    bool orderExist = NO;
    NSMutableString *myCSVString = [[NSMutableString alloc] init];
    
    if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
    { 
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT HOISTSRL, CUSTOMERNAME, DATE FROM CRANES_DONE"];
        const char *select_stmt = [selectSQL UTF8String];
        if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                orderExist = YES;
                const char *chHoistSrl = (char*) sqlite3_column_text(statement, 0);
                const char *chCustName = (char*) sqlite3_column_text(statement, 1);
                const char *chDate = (char*) sqlite3_column_text(statement, 2);
                
                NSString *hoistSrl = [NSString stringWithUTF8String:chHoistSrl];
                NSString *custName = [NSString stringWithUTF8String:chCustName];
                NSString *date = [NSString stringWithUTF8String:chDate];
                
                [myCSVString appendString:[NSString stringWithFormat:@"%@,%@,%@,\n", hoistSrl, custName, date]];
                
                NSLog(@"Retrieved condition from the table");
                //release memory
                chHoistSrl = nil;
                chCustName = nil;
                chDate = nil;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Updated Succesfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        else {
            NSLog(@"Failed to find jobnumber in table");
        }
    }
    [self WriteCSVFile:myCSVString];
    //release memory
    dbPath = nil;
    myCSVString = nil;
}
- (void) WriteCSVFile:(NSString *) csvString
{
    NSLog(@"csvString:%@",csvString);
    
    // Create .csv file and save in Documents Directory.
    
    //create instance of NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //create an array and store result of our search for the documents directory in it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //create NSString object, that holds our exact path to the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"Document Dir: %@",documentsDirectory);
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Cranes.csv", owner]]; //add our file to the path
    [fileManager createFileAtPath:fullPath contents:[csvString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]; //finally save the path (file)
    [self UploadCSVFileToDropbox:fullPath];
    //release memory
    fileManager = nil;
    paths = nil;
    documentsDirectory = nil;
    fullPath = nil;
}

//Grab the crane information from the WATERDISTRICTCRANES table with the HoistSrl as the identifier and then insert the results onto the home page
//Automatically insert the customerName, customerContact, Address and Email
- (IBAction)LoadHoistSrlPressed:(id)sender {
    sqlite3_stmt *statement;
    bool waterDistrictCrane = NO;
    const char *dbPath = [databasePath UTF8String];
    bool craneExist=NO;
    if (![txtHoistSrl.text isEqualToString:@""])
    {
        if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
        { 
            //grab only the crane information from the WATERDISTRICTCRANES table, which simply contains the water district cranes
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT TYPE, CAPACITY, MDL_HOIST, SRL_CRANE_MFG, MANUFACTURER, UNIT_ID FROM WATERDISTRICTCRANES WHERE SRL_HOIST=\"%@\"", txtHoistSrl.text];   
            const char *select_stmt = [selectSQL UTF8String];
            if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
            {
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    craneExist = YES;
                    const char *type = (char*) sqlite3_column_text(statement, 0);           //information at first column
                    const char *capacity = (char*) sqlite3_column_text(statement, 1);       //second column
                    const char *mdlHoist = (char*) sqlite3_column_text(statement, 2);       //third column
                    const char *srlCraneMfg = (char*) sqlite3_column_text(statement, 3);    //fourth column
                    const char *myManufacturer = (char*) sqlite3_column_text(statement, 4);
                    const char *equipNum = (char*) sqlite3_column_text(statement, 5);
                    //const char *manufacturer = (char*) sqlite3_column_text(statement, 4);
                    
                   // NSString *custName = txtCustomerName.text;
                    NSString *hoistSrl = txtHoistSrl.text;
                    
                    [self EmptyTextFields];
                    
                    txtHoistSrl.text = hoistSrl;
                    
                    //-----------------------Water district information -----------------
                    txtCustomerName.text = @"LVVWD";
                    txtCustomerContact.text = @"DAVID BOURN";
                    txtAddress.text = @"1001 S VALLEY VIEW BLVD, LAS VEGAS, NV 89107";
                    txtEmail.text = @"DAVID.BOURN@LVVWD.COM";
                    //txtCustomerName.text = custName;
                    //txtCustomerName.text = [NSString stringWithUTF8String:manufacturer];
                    txtCraneDescription.text = [NSString stringWithUTF8String:type];    //store type
                    txtCap.text = [NSString stringWithUTF8String:capacity];             //store cap
                    txtHoistMdl.text = [NSString stringWithUTF8String:mdlHoist];        //store hoistMdl
                    txtCraneSrl.text = [NSString stringWithUTF8String:srlCraneMfg];     //store CraneSrl
                    lblCraneDesc.text = [NSString stringWithUTF8String:type];           //store CraneDesc
                    txtEquipNum.text = [NSString stringWithUTF8String:equipNum];
                    manufacturer = [NSString stringWithUTF8String:myManufacturer];
                    
                    NSLog(@"Retrieved condition from the table");
                    //release memory
                    type = nil;
                    capacity = nil;
                    mdlHoist = nil;
                    srlCraneMfg = nil;
                    equipNum = nil;
                    hoistSrl = nil;
                    waterDistrictCrane = YES;
                }
            }
            else {
                NSLog(@"Failed to find jobnumber in table");
            }
            //Grab customer and crane information from the JOBS table with the srl hoist as the identifier
            selectSQL = [NSString stringWithFormat:@"SELECT HOISTSRL, CUSTOMERNAME, CONTACT, DATE, ADDRESS, EMAIL, EQUIPNUM, CRANEMFG, HOISTMFG, HOISTMDL, CRANEDESCRIPTION, CAP, CRANESRL, JOBNUMBER FROM JOBS WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
            select_stmt = [selectSQL UTF8String];
            if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    waterDistrictCrane = NO;
                    craneExist = YES;
                    //get the information from the table
                    const char *hoistSrl = (char*) sqlite3_column_text(statement, 0);                   //info at column 1: HOISTSRL
                    const char *custName = (char*) sqlite3_column_text(statement, 1);                   //column 2: CUSTOMERNAME
                    const char *contact = (char*) sqlite3_column_text(statement, 2);                    //column 3: CONTACT
                    const char *date = (char*) sqlite3_column_text(statement, 3);                       //column 4: DATE
                    const char *address = (char*) sqlite3_column_text(statement, 4);                    //column 5: ADDRESS
                    const char *email = (char*) sqlite3_column_text(statement, 5);                      //column 6: EMAIL
                    const char *equipNum = (char*) sqlite3_column_text(statement, 6);                   //column 7: EQUIPNUM
                    const char *craneMfg = (char*) sqlite3_column_text(statement, 7);                   //column 8: CRANEMFG
                    const char *hoistMfg = (char*) sqlite3_column_text(statement, 8);                   //column 9: HOISTMFG
                    const char *hoistMdl = (char*) sqlite3_column_text(statement, 9);                   //column 10: HOISTMDL
                    const char *craneDescription = (char*) sqlite3_column_text(statement, 10);          //column 11: CRANEDESCRIPTION
                    const char *cap = (char*) sqlite3_column_text(statement, 11);                       //column 12: CAP
                    const char *craneSrl = (char*) sqlite3_column_text(statement, 12);                  //column 13: CRANESRL
                    const char *chJobNumber = (char*) sqlite3_column_text(statement, 13);               //column 14: JOBNUMBER
                    //makes sure that the job number stays displayed
                    
                    //txtJobNumber.text = [NSString stringWithUTF8String:chJobNumber];
                    txtHoistSrl.text = [NSString stringWithUTF8String:hoistSrl];
                    txtDate.text = [NSString stringWithUTF8String:date];
                    if (waterDistrictCrane == YES)
                    {
                        txtCustomerName.text = @"LVVWD";
                        txtCustomerContact.text = @"DAVID BOURN";
                        txtAddress.text = @"1001 S VALLEY VIEW BLVD, LAS VEGAS, NV 89107";
                        txtEmail.text = @"DAVID.BOURN@LVVWD.COM";
                    }
                    else {
                        txtCustomerName.text = [NSString stringWithUTF8String:custName];
                        txtCustomerContact.text = [NSString stringWithUTF8String:contact];
                        txtAddress.text = [NSString stringWithUTF8String:address];
                        txtEmail.text = [NSString stringWithUTF8String:email];
                    }
                    txtEquipNum.text = [NSString stringWithUTF8String:equipNum];
                    txtCraneMfg.text = [NSString stringWithUTF8String:craneMfg];
                    txtHoistMfg.text = [NSString stringWithUTF8String:hoistMfg];
                    txtHoistMdl.text = [NSString stringWithUTF8String:hoistMdl];
                    if ([txtCraneDescription.text isEqualToString:@""])
                    {
                        txtCraneDescription.text = [NSString stringWithUTF8String:craneDescription];
                    }
                    if ([txtCap.text isEqualToString:@""])
                    {
                        txtCap.text = [NSString stringWithUTF8String:cap];
                        
                    }
                    if ([txtCraneSrl.text isEqualToString:@""])
                    {
                        txtCraneSrl.text = [NSString stringWithUTF8String:craneSrl];
                    }
                    if ([txtEquipNum.text isEqualToString:@""])
                    {
                        txtEquipNum.text = [NSString stringWithUTF8String:equipNum];
                    }
                    if ([lblCraneDesc.text isEqualToString:@""])
                    {
                        lblCraneDesc.text = [NSString stringWithUTF8String:craneDescription];
                    }
                    txtJobNumber.text = [NSString stringWithUTF8String:chJobNumber];
                    NSLog(@"Retrieved condition from the table");
                    //release memory
                    hoistSrl = nil;
                    date = nil;
                    equipNum = nil;
                    craneMfg = nil;
                    hoistMfg = nil;
                    hoistMdl = nil;
                    craneDescription = nil;
                    cap = nil;
                    craneSrl = nil;
                    chJobNumber = nil;
                }
            }
            else {
                NSLog(@"Failed to find jobnumber in table");
            }
            //if this crane does not exist, which means that it is not a water district crane then display that it does not exist
            if (craneExist ==NO)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO CRANE" message:@"No CRANE by this HOIST SERIAL NUMBER was found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK"    , nil];
                [alert show];
            }
            else {
                myItemListStore = [[ItemListConditionStorage alloc] init:myPartsArray];
                optionLocation = 0;
                [self changeLayout:optionLocation];
            }
        }
    }
    [self OpenOrderFromField:txtHoistSrl];
}

//this method will need to open the order by getting both the hoist srl number or equip number and the job number so that they can get any hoist srl at any time
- (void) OpenOrderFromField: (UITextField *) input;
{
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    int counter=0;
    bool orderExist = NO;
    NSString *selectSQL = [[NSString alloc] init];
    const char *select_stmt;
    
    if (sqlite3_open(dbPath, &contactDB)==SQLITE_OK)
    { 
        if ([input.text isEqualToString:txtHoistSrl.text])
        {
            selectSQL = [NSString stringWithFormat:@"SELECT part, deficient, deficientpart, notes, pickerselection, applicable FROM ALLORDERS WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
            select_stmt = [selectSQL UTF8String];
        }
        else {
            selectSQL = [NSString stringWithFormat:@"SELECT part, deficient, deficientpart, notes, pickerselection, applicable FROM ALLORDERS WHERE EQUIPNUM=\"%@\"", txtEquipNum.text];
            select_stmt = [selectSQL UTF8String];
        }
        if (sqlite3_prepare_v2(contactDB, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            @try
            {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                orderExist = YES;
                const char *chDeficient = (char*) sqlite3_column_text(statement, 1);
                const char *chDeficientPart = (char*) sqlite3_column_text(statement, 2);
                const char *chNotes = (char*) sqlite3_column_text(statement, 3);
                const char *chPickerSelection = (char*) sqlite3_column_text(statement, 4);
                const char *chApplicable = (char*) sqlite3_column_text(statement, 5);
        
                BOOL myDeficient = [[NSString stringWithUTF8String:chDeficient] boolValue];
                BOOL myApplicable = [[NSString stringWithUTF8String:chApplicable] boolValue];
                NSString *myDeficientPart = [NSString stringWithUTF8String:chDeficientPart];
                NSString *myNotes = [NSString stringWithUTF8String:chNotes];
                NSUInteger *myPickerSelection = (NSUInteger *) [[NSString stringWithUTF8String:chPickerSelection] integerValue];
            
                Condition *myCondition = [[Condition alloc] initWithParameters:myNotes:myDeficient:myPickerSelection:myDeficientPart:myApplicable];
                [myItemListStore setCondition:counter:myCondition];
                counter++;
                NSLog(@"Retrieved condition from the table");
                //release memory
                chDeficient = nil;
                chDeficientPart = nil;
                chNotes = nil;
                chPickerSelection = nil;
                chApplicable = nil;
                myDeficientPart = nil;
                myNotes = nil;
                myPickerSelection = nil;
            }
            }
            @catch (NSException *exception)
            {
                NSLog(@"Loaded more values than exist for crane.");
            }
            if (orderExist == NO)
            {
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NO JOB" message:@"No INSPECTION by this JOB NUMBER was found" delegate:self cancelButtonTitle:nilotherButtonTitles:@"OK"    , nil]
                    //[alert show];
            }
            else {
                optionLocation = 0;
                [self changeLayout:optionLocation];
            }
            //   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Did retrieve succesfully" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"ok", nil];
            //  [alert show];
        }
        else {
            NSLog(@"Failed to find jobnumber in table");
        }
    }

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

- (IBAction)openInClicked:(id)sender {

}
//Saves the job information which will contain the entire inspection results into the ALLORDERS table
- (void) saveData:(ItemListConditionStorage *) myConditionsList {
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    NSString *isDeficient = [[NSString alloc] init];
    NSString *isApplicable = [[NSString alloc] init];
    //check to make sure that the database is correct
    if (sqlite3_open(dbPath, &contactDB) == SQLITE_OK)
    {
        //Delete job with this job number from the table
        NSString *removeSQL = [NSString stringWithFormat:@"DELETE FROM ALLORDERS WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
        const char *remove_stmt = [removeSQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, remove_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            //sqlite3_bind_text(statement, 1, [txtJobNumber.text UTF8String], -1, NULL);
        }
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"removed succesfully");
        }
        removeSQL = [NSString stringWithFormat:@"DELETE FROM ALLORDERS WHERE EQUIPNUM=\"%@\"", txtEquipNum.text];
        remove_stmt = [removeSQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, remove_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            //sqlite3_bind_text(statement, 1, [txtJobNumber.text UTF8String], -1, NULL);
        }
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"removed succesfully");
        }
        
        sqlite3_finalize(statement);
        
        //goes through all the different conditions in the conditionList and sets the condition to whatever is stored within the table
        for (int i = 0; i < myItemListStore.myConditions.count; i ++) {
            //grabs the current condition
            Condition *myCondition = [myItemListStore.myConditions objectAtIndex:i];
            if (myCondition.deficient == YES)
            {
                isDeficient = @"YES";
            }
            else {
                isDeficient = @"NO";
            }
            if (myCondition.applicable==YES)
            {
                isApplicable = @"YES";
            }
            else {
                isApplicable=@"NO";
            }
            //inserts the current condition in the row
            pickerSelection =  [NSString stringWithFormat:@"%d", myCondition.pickerSelection];
        
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLORDERS (HOISTSRL, JOBNUMBER, EQUIPNUM, PART, DEFICIENT, DEFICIENTPART, NOTES, PICKERSELECTION, APPLICABLE) VALUES(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\");", 
                txtHoistSrl.text,
                txtJobNumber.text,
                txtEquipNum.text,
                (NSString *)[myPartsArray objectAtIndex:i],
                (NSString *) isDeficient,
                myCondition.deficientPart, 
                [myCondition.notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\\"],
                pickerSelection,
                (NSString *) isApplicable];
            //NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLORDERS (JOBNUMBER, PART, DEFICIENT, DEFICIENTPART, NOTES, PICKERSELECTION) VALUES (?,?,?,?,?,?)"];
            
            const char *insert_stmt = [insertSQL UTF8String];
        
            sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, nil);

            if (sqlite3_step(statement) != SQLITE_DONE)
            {
                NSAssert(0, @"Error updating table: ALLORDERS");
            }
            else {
                NSLog(@"Inserted successfully");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(contactDB);
        
        dbPath = nil;
        isDeficient = nil;
        isApplicable = nil;
    }
}

- (void) writeCertificateTextFile
{
    if (![testLoads isEqual:NULL])
    {
    NSMutableString *headerString = [NSMutableString stringWithString:@""];
    NSMutableString *ownerString = [NSMutableString stringWithString:@""];
    NSMutableString *ownerAddressString = [NSMutableString stringWithString:@""];
    NSMutableString *device = [NSMutableString stringWithString:@""];
    NSMutableString *location = [NSMutableString stringWithString:@""];
    NSMutableString *description = [NSMutableString stringWithString:@""];
    NSMutableString *ratedCapacity = [NSMutableString stringWithString:@""];
    NSMutableString *craneManafacturer = [NSMutableString stringWithString:@""];
    NSMutableString *modelCrane = [NSMutableString stringWithString:@""];
    NSMutableString *serialNoCrane = [NSMutableString stringWithString:@""];
    NSMutableString *hoistManufacturer = [NSMutableString stringWithString:@""];
    NSMutableString *modelHoist = [NSMutableString stringWithString:@""];
    NSMutableString *serialNoHoist = [NSMutableString stringWithString:@""];
    NSMutableString *ownerID = [NSMutableString stringWithString:@""];
    NSMutableString *lifting = [NSMutableString stringWithString:@""];
    NSMutableString *other = [NSMutableString stringWithString:@""];
    NSMutableString *testLoadsString = [NSMutableString stringWithString:@""];
    NSMutableString *proofLoadString = [NSMutableString stringWithString:@""];
    NSMutableString *loadRatingsString = [NSMutableString stringWithString:@""];
    NSMutableString *remarksLimitationsString = [NSMutableString stringWithString:@""];
    NSMutableString *footer = [NSMutableString stringWithString:@""];
    NSMutableString *nameAddress = [NSMutableString stringWithString:@""];
    NSMutableString *expirationDate = [NSMutableString stringWithString:@""];
    NSMutableString *signature = [NSMutableString stringWithString:@""];
    NSMutableString *title = [NSMutableString stringWithString:@""];
    NSMutableString *inspectorName = [NSMutableString stringWithString:@""];
    NSMutableString *certificateNum = [NSMutableString stringWithString:@""];
    NSMutableString *date = [NSMutableString stringWithString:@""];
    NSMutableString *address = [NSMutableString stringWithString:@""];
    NSMutableString *headerTitle = [NSMutableString stringWithString:@""];
    NSMutableString *titleAddress = [NSMutableString stringWithString:@""];
    
    [headerString appendString:@"ANNUAL OVERHEAD BRIDGE INSPECTION: \n"];
    [headerString appendString:[NSString stringWithFormat:@"%@", @"BRIDGE, MONORAIL, JIB"]];
    
    if ([txtCustomerName.text isEqualToString:@"LVVWD"]) 
    {
        [ownerString appendString:[NSString stringWithFormat:@"1.  Owner      %@", @"Las Vegas Valley Water District"]];
    }
    else {
        [ownerString appendString:[NSString stringWithFormat:@"1.  Owner     %@", txtCustomerName.text]];
    }
    
    [titleAddress appendString:[NSString stringWithFormat:@"Silver State Wire Rope & Rigging\n8740 S. Jones Blvd Las Vegas, NV 89139\n(702) 597-2010 fax (702)896-1977"]];
    [headerTitle appendString:[NSString stringWithFormat:@"Annual Overhead Crane Inspection:\n%@", txtCraneDescription.text]];
    [ownerAddressString appendString:[NSString stringWithFormat:@"2.  Owner's Address      %@", txtAddress.text]];
    [location appendString:[NSString stringWithFormat:@"3.  Location      %@", txtEquipNum.text]];
    [description appendString:[NSString stringWithFormat:@"4.  Description    %@ CRANE", txtCraneDescription.text]];
    [ratedCapacity appendString:[NSString stringWithFormat:@"    Rated Capacity      %@", txtCap.text]];
    [craneManafacturer appendString:[NSString stringWithFormat:@"5.  Crane Manufacturer"]];
    [modelCrane appendString:[NSString stringWithFormat:@"Model"]];
    [serialNoCrane appendString:[NSString stringWithFormat:@"Serial No."]];
    [hoistManufacturer appendString:[NSString stringWithFormat:@"6.  Hoist Manafacture"]];
    [modelHoist appendString:[NSString stringWithFormat:@"Model"]];
    [serialNoHoist appendString:[NSString stringWithFormat:@"Serial No."]];
    [ownerID appendString:[NSString stringWithFormat:@"7.  Owner's Identification (if any)      %@", txtEquipNum.text]];
    [testLoadsString appendString:[NSString stringWithFormat:@"8. Test loads applied (only if examination conducted):   %@", testLoads]];
    [proofLoadString appendString:[NSString stringWithFormat:@"9. Description of proof load:   %@", proofLoadDescription]];
    [loadRatingsString appendString:[NSString stringWithFormat:@"10. Basis for assigned load ratings:   %@", loadRatingsText]];
    [remarksLimitationsString appendString:[NSString stringWithFormat:@"11. Remarks and/or limitations imposed:   %@", remarksLimitationsImposed]];
    //convert the date of the inspection to the Long Date format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:txtDate.text];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateFromString];
    
    NSInteger day = [components day];
    //convert day to an NSNumber so that it can be sent to OrdinalNumberFormatter which will turn the NSNumber into an ORdinal Number
    NSNumber *myNumDay = [NSNumber numberWithInt:day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(month - 1)];  
    OrdinalNumberFormatter *formatter = [[OrdinalNumberFormatter alloc] init];
    
    NSString *myDay = [formatter stringForObjectValue:myNumDay];
    
    [footer appendString:[NSString stringWithFormat:@"I certify that on the %@ day of %@ %d the above described device was tested and \n examined by the undersigned; that said test and/or examination met with the requirements \n of the Division of Occupational Safety and Health Administration and ANSI B30 series or \nANSI/SIA A92.2 as applicable. ", myDay, monthName, year]];
    [nameAddress appendString:[NSString stringWithFormat:@"Name and address of authorized certificating agent: "]]; 
    [address appendString:[NSString stringWithFormat:@"SILVER STATE WIRE ROPE AND RIGGING\n8740 S. JONES BLVD.\nLAS VEGAS, NV 89139", txtCraneDescription.text]];
    [expirationDate appendString:[NSString stringWithFormat:@"Expiration Date:  %d/%d/%d", month, day, year + 1]];
    [signature appendString:[NSString stringWithFormat:@"Signature: "]];
    [title appendString:[NSString stringWithFormat:@"Title: Crane Surveyor"]];
    [inspectorName appendString:[NSString stringWithFormat:@"Name: %@", txtTechnicianName.text]];
    [certificateNum appendString:[NSString stringWithFormat:@"Certificate #LVVWD- %@", txtEquipNum.text]];
    [date appendString:[NSString stringWithFormat:@"Date:   %@", txtDate.text]];
    
    //Create the file
    
    NSError *error;
    
    //create file manager
    
    NSString *dateNoSlashes = [txtDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF",txtCustomerName.text, txtHoistSrl.text, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    //NSString *documentsDirectory = @"/Users/Developer/Documents";
    NSString *filePath = pdfFileName;
    //NSString *afilePath = [documentsDirectory stringByAppendingPathComponent:@"jobInfoArray.txt"];
    
   // NSLog(@"string to write:%@", printString);
    
    //[printString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self createCertificate:titleAddress
                           :headerTitle
                           :headerString
                           :ownerString
                           :ownerAddressString
                           :device
                           :location
                           :description
                           :ratedCapacity
                           :craneManafacturer
                           :modelCrane
                           :serialNoCrane
                           :hoistManufacturer
                           :modelHoist
                           :serialNoHoist
                           :ownerID
                           :lifting
                           :other
                           :testLoadsString
                           :proofLoadString
                           :loadRatingsString
                           :remarksLimitationsString
                           :footer
                           :nameAddress
                           :address
                           :expirationDate
                           :signature
                           :title
                           :inspectorName
                           :certificateNum
                           :date
                           :filePath];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must first fill out an application" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) createCertificate:(NSString *) titleAddress
                          :(NSString *) headerTitle
                          :(NSString *) headerString
                          :(NSString *) ownerString
                          :(NSString *) ownerAddressString
                          :(NSString *) device
                          :(NSString *) location
                          :(NSString *) description
                          :(NSString *) ratedCapacity
                          :(NSString *) craneManafacturer
                          :(NSString *) modelCrane
                          :(NSString *) serialNoCrane
                          :(NSString *) hoistManufacturer
                          :(NSString *) modelHoist
                          :(NSString *) serialNoHoist
                          :(NSString *) ownerID
                          :(NSString *) lifting
                          :(NSString *) other
                          :(NSString *) testLoadsString
                          :(NSString *) proofLoadString
                          :(NSString *) loadRatingsString
                          :(NSString *) remarksLimitationsString
                          :(NSString *) footer
                          :(NSString *) nameAddress
                          :(NSString *) address
                          :(NSString *) expirationDate
                          :(NSString *) signature
                          :(NSString *) title
                          :(NSString *) inspectorName
                          :(NSString *) certificateNum
                          :(NSString *) date
                          :(NSString *) filePath
{
    // Create URL for PDF file
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)fileURL, NULL, NULL);
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    UIImage *myImage = [UIImage imageNamed:@"logo.jpg"];
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    // Drawing commands
    //CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    //[printString drawAtPoint:CGPointMake(100, 100) withFont:[UIFont boldSystemFontOfSize:12.0f]];
    [myImage drawInRect:CGRectMake(-110, -30, 250, 250)];
    [myImage drawInRect:CGRectMake(50, 150, 500, 500) blendMode:kCGBlendModeLighten alpha:.15f];
    
    //Border lines
    //left vertical line
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 13, 231);
    CGContextAddLineToPoint(pdfContext, 13, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //right vertical lines
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 600, 13);
    CGContextAddLineToPoint(pdfContext, 600, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //top line
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 29, 13);
    CGContextAddLineToPoint(pdfContext, 600, 13);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //bottom line
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 13, 780);
    CGContextAddLineToPoint(pdfContext, 600, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    [titleAddress drawInRect:CGRectMake(95, 35, 270, 45) withFont:[UIFont systemFontOfSize:12.0]];
    [headerTitle drawInRect:CGRectMake(355, 35, 300, 50) withFont:[UIFont systemFontOfSize:12.0f]];
    
    //LINE 1
    [ownerString drawInRect:CGRectMake(50, 160, 500, 20) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    CGContextSetLineWidth(pdfContext, 1);
    
    CGContextSetStrokeColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 110, 175);
    CGContextAddLineToPoint(pdfContext, 550, 175);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 2
    [ownerAddressString drawInRect:CGRectMake(50, 190, 500 , 20) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 170, 205);
    CGContextAddLineToPoint(pdfContext, 550, 205);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 3
    [location drawInRect:CGRectMake(50, 220, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 120, 235);
    CGContextAddLineToPoint(pdfContext, 550, 235);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 4
    [description drawInRect:CGRectMake(50, 250, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 130, 265);
    CGContextAddLineToPoint(pdfContext, 260, 265);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 4 PART 2
    [ratedCapacity drawInRect:CGRectMake(255, 250, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];

    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 355, 265);
    CGContextAddLineToPoint(pdfContext, 550, 265);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 5
    [craneManafacturer drawInRect:CGRectMake(50, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 180, 295);
    CGContextAddLineToPoint(pdfContext, 265, 295);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);

    [txtCraneMfg.text drawInRect:CGRectMake(180, 280, 230, 20) withFont:[UIFont systemFontOfSize:10.0f]];
    
    //LINE 6 Part 2
    /*
    [modelCrane drawInRect:CGRectMake(270, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 310, 295);
    CGContextAddLineToPoint(pdfContext, 400, 295);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    [txtHoistMdl.text drawInRect:CGRectMake(310, 280, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    */
    
    //LINE 6 Part 3 
    [serialNoCrane drawInRect:CGRectMake(410, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 295);
    CGContextAddLineToPoint(pdfContext, 550, 295);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    [txtCraneSrl.text drawInRect:CGRectMake(470, 280, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 7
    [hoistManufacturer drawInRect:CGRectMake(50, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 170, 325);
    CGContextAddLineToPoint(pdfContext, 265, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    [txtHoistMfg.text drawInRect:CGRectMake(170, 310, 230, 20) withFont:[UIFont systemFontOfSize:10.0f]];
    
    //LINE 7 Part 2
    [modelHoist drawInRect:CGRectMake(270, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 310, 325);
    CGContextAddLineToPoint(pdfContext, 400, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    [txtHoistMdl.text drawInRect:CGRectMake(310, 310, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    
    //LINE 7 Part 3 
    [serialNoHoist drawInRect:CGRectMake(410, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 325);
    CGContextAddLineToPoint(pdfContext, 550, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    [txtHoistSrl.text drawInRect:CGRectMake(470, 310, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 325);
    CGContextAddLineToPoint(pdfContext, 550, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 8
    [ownerID drawInRect:CGRectMake(50, 340, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 230, 355);
    CGContextAddLineToPoint(pdfContext, 550, 355);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 9
    [testLoadsString drawInRect:CGRectMake(50, 370, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 340, 385);
    CGContextAddLineToPoint(pdfContext, 550, 385);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 10
    [proofLoadString drawInRect:CGRectMake(50, 400, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 210, 415);
    CGContextAddLineToPoint(pdfContext, 550, 415);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 11
    [loadRatingsString drawInRect:CGRectMake(50, 430, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 240, 445);
    CGContextAddLineToPoint(pdfContext, 550, 445);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 12
    [remarksLimitationsString drawInRect:CGRectMake(50, 460, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 270, 475);
    CGContextAddLineToPoint(pdfContext, 550, 475);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 14
    [footer drawInRect:CGRectMake(50, 495, 500, 120) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
    
    //LINE 15
    [nameAddress drawInRect:CGRectMake(50, 565, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    //LINE 16
    [address drawInRect:CGRectMake(330, 565, 500, 120) withFont:[UIFont systemFontOfSize:11.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 577);
    CGContextAddLineToPoint(pdfContext, 550, 577);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 590);
    CGContextAddLineToPoint(pdfContext, 445, 590);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 605);
    CGContextAddLineToPoint(pdfContext, 450, 605);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 17
    [expirationDate drawInRect:CGRectMake(50, 630, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 140, 645);
    CGContextAddLineToPoint(pdfContext, 300, 645);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 17 PART 2
    [signature drawInRect:CGRectMake(330, 630, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 390, 645);
    CGContextAddLineToPoint(pdfContext, 550, 645);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 18
    [title drawInRect:CGRectMake(50, 670, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 80, 685);
    CGContextAddLineToPoint(pdfContext, 170, 685);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 18 PART 2
    [inspectorName drawInRect:CGRectMake(330, 670, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 370, 685);
    CGContextAddLineToPoint(pdfContext, 550, 685);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 19
    [certificateNum drawInRect:CGRectMake(50, 710, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 165, 725);
    CGContextAddLineToPoint(pdfContext, 300, 725);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 19 PART 2
    [date drawInRect:CGRectMake(330, 710, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 365, 725);
    CGContextAddLineToPoint(pdfContext, 550, 725);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    
    [self displayComposerSheet];
    // Clean up
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);  
    //release memory
    fileURL = nil;
    pdfContext = nil;
    myImage = nil;
}

//This text file that is written contains all the information that has been created: Customer Information; Crane Information; and Inspection Information
- (void) writeTextFile: (ItemListConditionStorage *) myConditionList {
    NSMutableString *printString = [NSMutableString stringWithString:@""];
    NSMutableString *customerInfoResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionLeftColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionRightColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionRightResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *partTitle = [NSMutableString stringWithString:@""];
    NSMutableString *partDeficiency = [NSMutableString stringWithString:@""];
    NSMutableString *partNotes = [NSMutableString stringWithString:@""];
    NSMutableString *deficientPartString = [NSMutableString stringWithString:@""];
    NSMutableString *footerLeft = [NSMutableString stringWithString:@""];
    NSMutableString *footerRight = [NSMutableString stringWithString:@""];
    NSMutableString *header = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescription = [NSMutableString stringWithString:@""];
    //customer information titles and descriptions
    [printString appendString:@"Customer Information\n\n"];
    [printString appendString:[NSMutableString stringWithFormat:@"Customer Name:\n", customerName]];
    [printString appendString:[NSString stringWithFormat:@"Customer Contact:\n", txtCustomerContact.text]];
    [printString appendString:[NSString stringWithFormat:@"Job Number:\n", jobnumber]];
    [printString appendString:[NSString stringWithFormat:@"Email Address:\n", txtEmail.text]];
    [printString appendString:[NSString stringWithFormat:@"Customer Address:\n\n", txtAddress.text]];
    //the customer information results
    [customerInfoResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", txtCustomerName.text]];
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtCustomerContact.text]];
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtJobNumber.text]];
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtEmail.text]];
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n\n", txtAddress.text]];
    
    [craneDescription appendString:[NSString stringWithFormat:@"Crane Description: %@", txtCraneDescription.text]];
    //the crane description titles
    [craneDescriptionLeftColumn appendString:@"Overall Condition Rating:\n"];
    [craneDescriptionLeftColumn appendString:@"Crane Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Model:\n"];
    //crane description results
    [craneDescriptionResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", overallRating]];
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtCraneMfg.text]];
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtHoistMfg.text]];
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtHoistMdl.text]];
    //crane description titles right column
    [craneDescriptionRightColumn appendString:@"\n\nCap:\n"];
    [craneDescriptionRightColumn appendString:@"Crane Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Hoist Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Equip #:\n"];
    //creane description results
    [craneDescriptionRightResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", txtCap.text]];
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtCraneSrl.text]];
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtHoistSrl.text]];
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", txtEquipNum.text]];
    
    [footerLeft appendString:[NSString stringWithFormat:@"Technician:%@\nDate: %@",txtTechnicianName.text, txtDate.text]];
    [footerRight appendString:[NSString stringWithFormat:@"Customer:%@\nDate: %@",txtCustomerName.text, txtDate.text]];
    
    [header appendString:[NSString stringWithFormat:@"Silverstate Wire Rope and Rigging\n\n24-Hour Emergency Service\nSales - Service - Repair\nElectrical - Mechanical - Pneumatic\nCal-OSHA Accredited"]];
   
    for (int i = 0; i < myItemListStore.myConditions.count; i++)
    {
        Condition *myCondition = [myItemListStore.myConditions objectAtIndex:i];
        if (myCondition.applicable == NO)
        {
            if (myCondition.deficient == YES){
                [partDeficiency appendString:@"Failed\n"];
                [partNotes appendString:[NSString stringWithFormat:@"%d.  %@: %@\n",i + 1, myCondition.deficientPart, myCondition.notes]];
            }
            else if (myCondition.deficient==NO) {
                if (![myCondition.notes isEqualToString:@""])
                {
                    [partNotes appendString:[NSString stringWithFormat:@"%d.  %@\n",i + 1, myCondition.notes]];
                }
                [partDeficiency appendString:@"Passed\n"];
            }
        }
        else {
            [partDeficiency appendString:@"N/A\n"];
        }
        [partTitle appendString:[NSString stringWithFormat:@"%d. %@\n",i + 1, (NSString *)[myPartsArray objectAtIndex:i]]];
        //[deficientPartString appendString:[NSString stringWithFormat:@"%@\n", myCondition.deficientPart]];
    }
    
    //Create the file
    
    NSError *error;
    
    //create file manager
    
    NSString *dateNoSlashes = [txtDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF",txtCustomerName.text, txtHoistSrl.text, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    //NSString *documentsDirectory = @"/Users/Developer/Documents";
    NSString *filePath = pdfFileName;
    //NSString *afilePath = [documentsDirectory stringByAppendingPathComponent:@"jobInfoArray.txt"];
    
    NSLog(@"string to write:%@", printString);
    
    [printString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self CreatePDFFile:printString
                       :customerInfoResultsColumn
                       :craneDescriptionLeftColumn
                       :craneDescriptionResultsColumn
                       :craneDescriptionRightColumn
                       :craneDescriptionRightResultsColumn
                       :filePath
                       :partDeficiency
                       :partTitle
                       :partNotes
                       :deficientPartString
                       :footerLeft
                       :footerRight
                       :header
                       :craneDescription];
    //release memory
    
    printString = nil;
    customerInfoResultsColumn = nil;
    craneDescriptionLeftColumn = nil;
    craneDescriptionResultsColumn = nil;
    craneDescriptionRightColumn = nil;
    craneDescriptionRightResultsColumn = nil;
    filePath = nil;
    partDeficiency = nil;
    partTitle = nil;
    partNotes = nil;
    deficientPartString = nil;
    footerLeft = nil;
    footerRight = nil;
    header = nil;
    craneDescription = nil;
}

- (void) CreatePDFFile:(NSString *) printString
                      :(NSString *) customerInfoResultsColumn
                      :(NSString *) craneDescriptionLeftColumn
                      :(NSString *) craneDescriptionResultsColumn
                      :(NSString *) craneDescriptionRightColumn
                      :(NSString *) craneDescriptionRightResultsColumn
                      :(NSString *) filePath
                      :(NSString *) partDeficiency
                      :(NSString *) partTitle
                      :(NSString *) partNotes
                      :(NSString *) deficientPartString
                      :(NSString *) footerLeft
                      :(NSString *) footerRight
                      :(NSString *) header
                      :(NSString *) craneDescription
{
    // Create URL for PDF file
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)fileURL, NULL, NULL);
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    UIImage *myImage = [UIImage imageNamed:@"logo.jpg"];
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    NSString *conditionRatingString = [[NSString alloc] initWithString:@"Crane Condition Rating: \n1=Great \n2=Good Minor Problems (scheduled repair) \n3=Maintenance Problems(Immediate Repair) \n4=Safety Concern(Immediate Repair) \n5=Crane's conditions require it to be taged out"];
    
    // Drawing commands
    //[printString drawAtPoint:CGPointMake(100, 100) withFont:[UIFont boldSystemFontOfSize:12.0f]];
    [myImage drawInRect:CGRectMake(50, 150, 500, 500) blendMode:kCGBlendModeLighten alpha:.15f];
    [header drawInRect:CGRectMake(20, 20, 200, 200) withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    [printString drawInRect:CGRectMake(225, 20, 120 , 120) withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    [customerInfoResultsColumn drawInRect:CGRectMake(325, 20, 400, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescription drawInRect:CGRectMake(20, 120, 500, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionLeftColumn drawInRect:CGRectMake(20, 145, 120, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionResultsColumn drawInRect:CGRectMake(140, 120, 150, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightColumn drawInRect:CGRectMake(300, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightResultsColumn drawInRect:CGRectMake(410, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [partTitle drawInRect:CGRectMake(20, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partDeficiency drawInRect:CGRectMake(235, 220, 120, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partNotes drawInRect:CGRectMake(310, 220, 220, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [deficientPartString drawInRect:CGRectMake(500, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [conditionRatingString drawInRect:CGRectMake(20, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerLeft drawInRect:CGRectMake(300, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerRight drawInRect:CGRectMake(450, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    // Clean up
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);   
    [self displayComposerSheet];
    //release memory
    fileURL = nil;
    pdfContext = nil;
    myImage = nil;
    conditionRatingString = nil;
}

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

- (void) displayComposerSheet
{
    /*
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Your Inspection Results"];
    
    // Set up the recipients.
    NSArray *toRecipients = [NSArray arrayWithObjects:@"adeiji@yahoo.com",
                             nil];
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"adebayoiji@gmail.com",
                             @"third@example.com", nil];
    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com",
                              nil];
    
    [picker setToRecipients:toRecipients];
    [picker setCcRecipients:ccRecipients];
    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email.
    NSString *path = @"/Users/Developer/Documents/jobInfo.pdf";
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"application/pdf"
                     fileName:@"jobInfo.pdf"];
    
    // Fill out the email body text.
    NSString *emailBody = @"Here is your inspection information!";
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentModalViewController:picker animated:YES];
    // Can safely release the controller now.
    
   
    NSString *fileToOpen = @"/Users/Developer/Documents/jobInfo.pdf";
    
    controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fileToOpen]];
    controller.delegate = self;
    
    CGRect navRect = secondViewController.navigationController.navigationBar.frame;
    navRect.size = CGSizeMake(1500.0f, 40.0f);
    [controller presentOpenInMenuFromRect:navRect inView:viewPDFController.view animated:YES];
*/
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotate
{
    return NO;
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

- (void) changePickerArray: (NSMutableArray*)input {
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
        [self saveData:myItemListStore];    //save the current condition so that if the user goes to the next part and back, the correct information will be displayed
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

- (void)InsertCraneIntoTable
{
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &contactDB) == SQLITE_OK)
    {
        NSString *removeSQL = [NSString stringWithFormat:@"DELETE FROM CRANES_DONE WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
        const char *remove_stmt = [removeSQL UTF8String];
        
        if (sqlite3_prepare_v2(contactDB, remove_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            //sqlite3_bind_text(statement, 1, [txtJobNumber.text UTF8String], -1, NULL);
        }
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"removed succesfully");
        }

        NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO CRANES_DONE (HOISTSRL, CUSTOMERNAME, DATE) VALUES(\"%@\", \"%@\", \"%@\");",
                           txtHoistSrl.text,
                           txtCustomerName.text,
                           txtDate.text];
        //NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLORDERS (JOBNUMBER, PART, DEFICIENT, DEFICIENTPART, NOTES, PICKERSELECTION) VALUES (?,?,?,?,?,?)"];
    
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, nil);
        
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table: CRANES");
        }
    }
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
        //NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLORDERS (JOBNUMBER, PART, DEFICIENT, DEFICIENTPART, NOTES, PICKERSELECTION) VALUES (?,?,?,?,?,?)"];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
      //  sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, nil);
        
      //  if (sqlite3_step(statement) != SQLITE_DONE)
       // {
        //    NSAssert(0, @"Error updating table: IPADOWNER");
       // }
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
        if ([deficientPart isEqualToString:@"Hoist Control Panel"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Additional Information" message:@"Is this a pendant or radio, and what is the manufacturer and model" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
        else if ([deficientPart isEqualToString:@"Trolley VFD/Soft/Start/Resistor"])
        {
            timesShown=0;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Length:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
        else if ([deficientPart isEqualToString:@"Hoist Upper Tackle"])
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
                    if (timesShown==0&&optionLocation==22)
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

-(void) DisplayPDFWithOverallRating
{
    [self writeTextFile:myItemListStore];
    //[CraneInspectionView removeFromSuperview];
    
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
  
    //  CGRect navRect = self.navigationController.navigationBar.frame;
  //  navRect.size = CGSizeMake(1500.0f, 40.0f);
    
    //[controller presentOpenInMenuFromRect:navRect inView:CraneInspectionView animated:NO];
    [controller presentPreviewAnimated:NO];
    //[CraneInspectionView removeFromSuperview];
    //[self.view addSubview:self.autographController.view];
    [self writeCertificateTextFile];
}

- (IBAction)partsListButtonClicked:(id)sender{
    Parts *parts = [[Parts alloc] init : txtCraneDescription.text];
    myItemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];
    [lblPart awakeFromNib];
    myPartsArray = [parts myParts];
    [self fillOptionArrays];
    [self changeLayout:optionLocation];
    [self.CustomerInfoFullView removeFromSuperview];
    [self.view insertSubview:self.CraneInspectionView atIndex:0];
}



- (IBAction)buttonPressed:(id)sender {
}

//This method saves the information in the conditions list
- (void) saveInfo:(NSString *) myNotes:(BOOL) myDeficient:(NSUInteger) mySelection: (NSString *) myDeficientPart: (BOOL) myApplicable {
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

- (void) InsertCustomerIntoTable
{
    sqlite3_stmt *statement;
    const char *dbPath = [databasePath UTF8String];
    
    //Delete job with this job number from the table
    NSString *removeSQL = [NSString stringWithFormat:@"DELETE FROM JOBS WHERE HOISTSRL=\"%@\"", txtHoistSrl.text];
    const char *remove_stmt = [removeSQL UTF8String];
    
    if (sqlite3_prepare_v2(contactDB, remove_stmt, -1, &statement, NULL)==SQLITE_OK)
    {
        //sqlite3_bind_text(statement, 1, [txtJobNumber.text UTF8String], -1, NULL);
    }
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
        NSLog(@"removed succesfully");
    }
    
    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO JOBS (HOISTSRL, CUSTOMERNAME, CONTACT, JOBNUMBER, DATE, ADDRESS, EMAIL, EQUIPNUM, CRANEMFG, HOISTMFG, HOISTMDL, CRANEDESCRIPTION, CAP, CRANESRL) VALUES(\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\");",
                           txtHoistSrl.text,
                           txtCustomerName.text,
                           txtCustomerContact.text,
                           txtJobNumber.text,
                           txtDate.text,
                           txtAddress.text,
                           txtEmail.text,
                           txtEquipNum.text,
                           txtCraneMfg.text,
                           txtHoistMfg.text,
                           txtHoistMdl.text,
                           txtCraneDescription.text,
                           txtCap.text,
                           txtCraneSrl.text];
    //NSString *insertSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO ALLORDERS (JOBNUMBER, PART, DEFICIENT, DEFICIENTPART, NOTES, PICKERSELECTION) VALUES (?,?,?,?,?,?)"];
    
    
    //check to make sure that the database is correct
    if (sqlite3_open(dbPath, &contactDB) == SQLITE_OK)
    {
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(contactDB, insert_stmt, -1, &statement, nil);
    
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            NSAssert(0, @"Error updating table: JOBS");
        }
        else {
            NSLog(@"Inserted successfully");
            //UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Customer Added" message:@"The Customer Contact Information was Saved" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            //[view show];
        }
    }

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
    
    if (CGRectContainsPoint(aRect, activeField.frame.origin)) {
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