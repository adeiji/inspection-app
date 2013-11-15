//
//  InspectionViewController.m
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import "InspectionViewController.h"
#import "Options.h"
#import "Parts.h"
#import "Customer.h"
#import "Crane.h"
#import "PDFGenerator.h"
#import "AppDelegate.h"
#import "Part.h"
#import "InspectionManager.h"
#import "InspectionBussiness.h"

@interface InspectionViewController ()
{
    int timesShown;
    int buttonIndex;
    
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
    
    NSArray *defficiencyPickerArray;
}
@end

@implementation InspectionViewController

@synthesize lblPartNumber;
@synthesize lblPart;
@synthesize applicableSwitch;
@synthesize defficiencyPicker;
@synthesize defficiencySwitch;
@synthesize txtNotes;
@synthesize pickerData;
@synthesize createCertificateButton;
@synthesize craneType = __craneType;
@synthesize partsArray = __partsArray;
@synthesize optionLocation = __optionLocation;
@synthesize validated = __validated;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    defficiencyPicker.delegate = self;
    defficiencyPicker.dataSource = self;
    
    [defficiencySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    [applicableSwitch addTarget:self action:@selector(applicableSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *gestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *gestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:gestureRecognizerRight];
    [self.view addGestureRecognizer:gestureRecognizerLeft];
    
    [self initiateParts];
    inspection = [InspectionManager sharedManager].inspection;
}


//Checks to see which way the user swiped
- (void) handleSwipe : (UISwipeGestureRecognizer*) sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextPressed];
    }
    else
    {
        [self previousPressed];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) changeLayout : (int) myOptionLocation
           PartsArray : (NSArray*) myPartsArray
        ItemListStore : (ItemListConditionStorage *) myItemListStore
{
    Condition *myCondition = [[Condition alloc] init ];
    myCondition = [myItemListStore.myConditions objectAtIndex:myOptionLocation];
    
    txtNotes.text = myCondition.notes;
    
    NSString* myPart = [myPartsArray objectAtIndex:__optionLocation];
    NSString* myPartNumber = [NSString stringWithFormat:@"Part #%d", myOptionLocation + 1];
    
    [lblPart setText:myPart];
    [lblPartNumber setText:myPartNumber];
    [defficiencyPicker selectRow:myCondition.pickerSelection inComponent:0 animated:YES];
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
        defficiencyPicker.userInteractionEnabled = YES;
        defficiencyPicker.alpha = 1;
        defficiencyPicker.showsSelectionIndicator = YES;
    }
    else {
        defficiencyPicker.userInteractionEnabled = NO;
        defficiencyPicker.showsSelectionIndicator = NO;
        defficiencyPicker.alpha = .5;
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

- (void )applicableSwitchChanged : (id)sender {
    if (applicableSwitch.on == YES)
    {
        defficiencySwitch.enabled = NO;
        defficiencyPicker.userInteractionEnabled = NO;
        defficiencyPicker.alpha = .5;
        defficiencyPicker.showsSelectionIndicator = NO;
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
            defficiencyPicker.userInteractionEnabled = YES;
            defficiencyPicker.alpha = 1;
            defficiencyPicker.showsSelectionIndicator = YES;
        }
    }
}

- (void) fillOptionArrays : (NSString*) currentPart {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    Options* myOptions = [[Options alloc] init:currentPart OptionsDictionary:delegate.optionsDictionary];
    
    defficiencyPickerArray = myOptions.optionsArray;
    //Send the array that contains the particular defficiencies unique to this part
    [self changePickerArray:defficiencyPickerArray];
}

//Change the array that contains the part details th at the Defficiency Picker will be showing
- (void) changePickerArray : (NSArray*) input {
    pickerData = nil;
    pickerData = input;
    [self.defficiencyPicker reloadAllComponents];
}

//Create the objects necessary to view the parts list
- (void) initiateParts
{
    //We need to get the parts that are unique to this particular crane.
    Parts *parts = [[Parts alloc] init:__craneType];

    //Get the actual array itself from the parts object
    __partsArray = [parts myParts];
    
    //Get the options that are unique to this particular part.
    [self fillOptionArrays:__partsArray[__optionLocation]];
    
    //Create the itemListStore which will store all the conditions as they are set.
    itemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];
    [self changeLayout:__optionLocation PartsArray:__partsArray ItemListStore:itemListStore];
    
    //Send the array that contains the particular defficiencies unique to this part
    [self changePickerArray:defficiencyPickerArray];
    inspectionComplete = NO;
}
//Check to see if all the values have been validated on the home page.  If so then we continue, if not, we return to the home page.
- (BOOL) validate
{
    if (__validated == YES)
    {
        return YES;
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
}

//On the deficiency information pages, when you press the submit button
- (IBAction)submitPressed:(id)sender {

    //If all the information is correctly inputed on the page, then we simply save the information.  Otherwise we go back so that the user can change whatever is necessary.
    if ([self validate]) {
        
        inspection.itemList = itemListStore;
        
        //if all the fields entered pass then, the the customer information is inserted and all the data is saved into a table
        NSUInteger selectedRow = [defficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[defficiencyPicker delegate]
                                     pickerView:defficiencyPicker
                                     titleForRow:selectedRow
                                     forComponent:0];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Overall Rating"
                              message:@"What is the overall condition rating?"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"ok", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        
        pageSubmitAlertView = YES;
        
        //Save the status of this page so that when going back to it we can view it as we left it
        [self saveInfo : txtNotes.text
                       : defficiencySwitch.on
                       : [defficiencyPicker selectedRowInComponent:0]
                       : myDeficientPart:applicableSwitch.on];
        
        
        //Get all the records with this hoistSrl and this specific date
        NSDictionary *query = @{ @"hoistSrl" : inspection.crane.hoistSrl, @"date" : inspection.date };
        
        [self saveInspectionToDatabase];
        
        inspectionComplete = YES;
        myDeficientPart = nil;
        loadRatings = @"";
        proofLoadDescription = @"";
        testLoad = @"";
        remarksLimitations = @"";
        
        [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:__partsArray];
        UIDocumentInteractionController *pdfViewController = [PDFGenerator DisplayPDFWithOverallRating:inspection];
        pdfViewController.delegate = self;
        [pdfViewController presentPreviewAnimated:NO];
    }
}

- (void) saveInspectionToDatabase
{
    DBAccount *account = [InspectionManager sharedManager].dropboxAccount;
    DBDatastore *dataStore = [InspectionManager sharedManager].dataStore;
    DBTable *table = [InspectionManager sharedManager].table;
    
    //this is the counter for the partsArray object index
    int i = 0;
    //Go through each condition in the current inspection and then write this information to the Datastore
    for (Condition *condition in inspection.itemList.myConditions)
    {
        
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
        int pickerSelection =  [NSString stringWithFormat:@"%d", (int) condition.pickerSelection];
        
        //Create the dictionary that contains all the information for this record.
        NSDictionary *conditionDictionary = [[NSDictionary alloc] initWithObjectsAndKeys
                                             :inspection.crane.hoistSrl, @"hoistsrl",
                                             inspection.jobNumber, @"jobnumber",
                                             inspection.crane.equipmentNumber, @"equipmentnumber",
                                             (NSString *)[__partsArray objectAtIndex:i], @"part",
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
    
    [dataStore sync:nil];
}

- (IBAction)gotoCustomerInfo:(id)sender {
    NSUInteger selectedRow = [defficiencyPicker selectedRowInComponent:0];
    NSString *myDeficientPart = [[defficiencyPicker delegate] pickerView:defficiencyPicker titleForRow:selectedRow forComponent:0];
    
    [self saveInfo:txtNotes.text :defficiencySwitch.on:[defficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) switchChanged : (id) sender {
    
    UISwitch *mySwitch = (UISwitch *)sender;
    BOOL setting = mySwitch.isOn;
    
    if (setting == TRUE) {
        defficiencyPicker.alpha = 1;
        defficiencyPicker.showsSelectionIndicator = YES;
        defficiencyPicker.userInteractionEnabled = YES;
        
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
        defficiencyPicker.alpha = .5;
        defficiencyPicker.showsSelectionIndicator = NO;
        defficiencyPicker.userInteractionEnabled = NO;
    }
    
}

- (CurrentState) setState
{
    if ((buttonIndex!=0 || loadRatings == YES || remarksLimitations == YES || finished == YES || proofLoad == YES) || (buttonIndex == 1 && testLoad == YES))
    {
        return FINAL_SUBMISSION_APPROVED;
    }
    
}

#pragma mark - Alert View Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
                    else if (timesShown==0&&__optionLocation==22)
                    {
                        timesShown++;
                        txtNotes.text = [NSString stringWithFormat:@"Length: %@ - %@",textField.text, txtNotes.text];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Size:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==1&&__optionLocation==22)
                    {
                        timesShown++;
                        txtNotes.text = [NSString stringWithFormat:@"Size: %@ - %@",textField.text, txtNotes.text];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Fittings:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==2&&__optionLocation==22)
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
                                    createCertificateButton.enabled = TRUE;
                                }
                                else {
                                    createCertificateButton.enabled = FALSE;

                                    [PDFGenerator DisplayPDFWithOverallRating:inspection];
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
                            testLoad = textField.text;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proof Load Description" message:@"Description of Proof Load" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                            [alert show];
                            loadRatings = YES;
                            proofLoad = NO;
                            testLoad = textField.text;
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
                            loadRatings = textField.text;
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remarks Limitations" message:@"Remarks and/or Limitations Imposed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                            [alert show];
                            remarksLimitations = NO;
                            finished = YES;
                            loadRatings = textField.text;
                        }
                        else if (finished == YES)
                        {
                            remarksLimitations = textField.text;
                            finished = NO;
                            [PDFGenerator DisplayPDFWithOverallRating : inspection];
                            
                            createCertificateButton.enabled = TRUE;
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
        [PDFGenerator DisplayPDFWithOverallRating:inspection];
    }
}

#pragma mark - Outlet methods

- (IBAction)gotoCustomerInformation : (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextPressed {
    if (__optionLocation < [__partsArray count] - 1) {
        NSUInteger selectedRow = [defficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[defficiencyPicker delegate] pickerView: defficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[defficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        __optionLocation = __optionLocation + 1;
        [self fillOptionArrays:__partsArray[__optionLocation]];
        [self changePickerArray:defficiencyPickerArray];
        [self changeLayout:__optionLocation PartsArray:__partsArray ItemListStore:itemListStore];
    }
}
- (IBAction)previousPressed {
    if (__optionLocation > 0) {
        NSUInteger selectedRow = [defficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[defficiencyPicker delegate] pickerView:defficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[defficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        __optionLocation = __optionLocation - 1;
        [self fillOptionArrays:__partsArray[__optionLocation]];
        [self changePickerArray:defficiencyPickerArray];
        [self changeLayout:__optionLocation PartsArray:__partsArray ItemListStore:itemListStore];
    }
}


//This method saves the information in the conditions list
- (void) saveInfo : (NSString *) myNotes
                  : (BOOL) myDeficient
                  : (NSUInteger) mySelection
                  : (NSString *) myDeficientPart
                  : (BOOL) myApplicable
{
    Condition *myCondition = [[Condition alloc] initWithParameters:myNotes Defficiency:myDeficient PickerSelection:mySelection DeficientPart:myDeficientPart Applicable:myApplicable];

    [itemListStore setCondition:__optionLocation Condition : myCondition];
    myCondition = nil;
}

#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    return 1;
}
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerData count];
}
#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [pickerData objectAtIndex:row];
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0f;
}

- (void) selectedOption : (NSString *) selection
{
    //If the item is contained in the picker, than we go straight to that in the picker.
    if ([defficiencyPickerArray containsObject:selection])
    {
        [defficiencyPicker selectRow:[defficiencyPickerArray indexOfObject:selection] inComponent:0 animated:YES];
    }
}

- (void) selectedPart:(Part *)currentPart
{
    //If the view controller has already been loaded then we continue to save the information on the current page.
    if (txtNotes != nil)
    {
        NSUInteger selectedRow = [defficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[defficiencyPicker delegate] pickerView: defficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:txtNotes.text :defficiencySwitch.on:[defficiencyPicker selectedRowInComponent:0]:myDeficientPart:applicableSwitch.on];
        
        //We need to get the parts that are unique to this particular crane.
        Parts *parts = [[Parts alloc] init:__craneType];
        
        //Get the actual array itself from the parts object
        __partsArray = [parts myParts];
        
        //Get the options that are unique to this particular part.
        [self fillOptionArrays:__partsArray[__optionLocation]];
        
        [self changePickerArray:defficiencyPickerArray];
        [self changeLayout:__optionLocation PartsArray:__partsArray ItemListStore:itemListStore];
    }
}
//This method gets the view controller that will display the UIDocumentInteractionController preview
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

@end
