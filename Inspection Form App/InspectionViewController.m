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
#import "InspectionCrane.h"
#import "PDFGenerator.h"
#import "AppDelegate.h"
#import "Part.h"
#import "InspectionManager.h"
#import "InspectionBussiness.h"
#import "MasterViewController.h"

@interface InspectionViewController ()

@end

@implementation InspectionViewController


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
	
    _deficiencyPicker.delegate = self;
    _deficiencyPicker.dataSource = self;
    
    [_deficiencySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    [_applicableSwitch addTarget:self action:@selector(applicableSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *gestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *gestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:gestureRecognizerRight];
    [self.view addGestureRecognizer:gestureRecognizerLeft];
    
    [self initiateParts];
    inspection = [InspectionManager sharedManager].inspection;
    
    //[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}


//Checks to see which way the user swiped
- (void) handleSwipe : (UISwipeGestureRecognizer*) sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self nextPressed];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SwipeDetected"
                                                            object:self
                                                          userInfo:@{
                                                                     @"part": _partsArray[_optionLocation],
                                                                    @"optionLocation": [NSNumber numberWithInt:_optionLocation] }];
    }
    else
    {
        [self previousPressed];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SwipeDetected"
                                                            object:self
                                                          userInfo:@{
                                                                     @"part": _partsArray[_optionLocation],
                                                                    @"optionLocation": [NSNumber numberWithInt:_optionLocation] }];
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
    
    _txtNotes.text = myCondition.notes;
    
    NSString* myPart = [myPartsArray objectAtIndex:_optionLocation];
    NSString* myPartNumber = [NSString stringWithFormat:@"Part #%d", myOptionLocation + 1];
    
    [_lblPart setText:myPart];
    [_lblPartNumber setText:myPartNumber];
    [_deficiencyPicker selectRow:myCondition.pickerSelection inComponent:0 animated:YES];
    [_deficiencySwitch setOn:myCondition.deficient];
    [_applicableSwitch setOn:myCondition.applicable];
    
    if ([_lblPart.text isEqualToString:@"Control Station Markings"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Additional Information" message:@"Is this a pendant or radio, and what is the manufacturer and model" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        pageSubmitAlertView = NO;
    }
    
    [self setDeficiencyViews];
}

- (void) setDeficiencyViews {
    if (_deficiencySwitch.isOn==YES) {
        _deficiencyPicker.userInteractionEnabled = YES;
        _deficiencyPicker.alpha = 1;
        _deficiencyPicker.showsSelectionIndicator = YES;
    }
    else {
        _deficiencyPicker.userInteractionEnabled = NO;
        _deficiencyPicker.showsSelectionIndicator = NO;
        _deficiencyPicker.alpha = .5;
    }
    if (_applicableSwitch.on == NO)
    {
        _deficiencySwitch.enabled = YES;
        _txtNotes.userInteractionEnabled = YES;
        _txtNotes.alpha = 1;
    }
    else {
        _deficiencySwitch.enabled = NO;
        _txtNotes.userInteractionEnabled = NO;
        _txtNotes.alpha = .5;
    }
}

- (void )_applicableSwitchChanged : (id)sender {
    if (_applicableSwitch.on == YES)
    {
        _deficiencySwitch.enabled = NO;
        _deficiencyPicker.userInteractionEnabled = NO;
        _deficiencyPicker.alpha = .5;
        _deficiencyPicker.showsSelectionIndicator = NO;
        _deficiencySwitch.on = NO;
        _txtNotes.userInteractionEnabled = NO;
        _txtNotes.alpha = .25;
        _txtNotes.text = @"";
    }
    else {
        _deficiencySwitch.enabled = YES;
        _txtNotes.alpha = 1;
        _txtNotes.userInteractionEnabled = YES;
        if (_deficiencySwitch.on == YES)
        {
            _deficiencyPicker.userInteractionEnabled = YES;
            _deficiencyPicker.alpha = 1;
            _deficiencyPicker.showsSelectionIndicator = YES;
        }
    }
}

- (void) fillOptionArrays : (NSString*) currentPart {
    Options* myOptions = [[Options alloc] initWithPart:currentPart];
    _deficiencyPickerArray = myOptions.optionsArray;
    //Send the array that contains the particular defficiencies unique to this part
    [self changePickerArray:_deficiencyPickerArray];
}

//Change the array that contains the part details th at the Defficiency Picker will be showing
- (void) changePickerArray : (NSArray*) input {
    _pickerData = nil;
    _pickerData = input;
    [_deficiencyPicker reloadAllComponents];
}

//Create the objects necessary to view the parts list
- (void) initiateParts
{
    //We need to get the parts that are unique to this particular crane.
    Parts *parts = [[Parts alloc] init:_craneType];
    _partsArray = [parts myParts];    //Get the actual array itself from the parts object
    [self fillOptionArrays:_partsArray[_optionLocation]];     //Get the options that are unique to this particular part.
    itemListStore = [[ItemListConditionStorage alloc] init:parts.myParts];       /*Create the itemListStore which will 
                                                                                  store all the conditions as they are set.*/
    [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:itemListStore];
    [self changePickerArray:_deficiencyPickerArray];    //Send the array that contains the particular deficiencies unique to this part
    inspectionComplete = NO;
}
//Check to see if all the values have been validated on the home page.  If so then we continue, if not, we return to the home page.
- (BOOL) validate
{
    if (_validated == YES)
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
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[_deficiencyPicker delegate]
                                     pickerView:_deficiencyPicker
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
        [self saveInfo : _txtNotes.text
                       : _deficiencySwitch.on
                       : [_deficiencyPicker selectedRowInComponent:0]
                       : myDeficientPart:_applicableSwitch.on];
        
        
        //Get all the records with this hoistSrl and this specific date
        NSDictionary *query = @{ @"hoistSrl" : inspection.crane.hoistSrl, @"date" : inspection.date };
        
        [self saveInspectionToDatabase];
        
        inspectionComplete = YES;
        myDeficientPart = nil;
        loadRatings = @"";
        proofLoadDescription = @"";
        testLoad = @"";
        remarksLimitations = @"";
        
        [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:_partsArray];
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
                                             (NSString *)[_partsArray objectAtIndex:i], @"part",
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
    NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
    NSString *myDeficientPart = [[_deficiencyPicker delegate] pickerView:_deficiencyPicker titleForRow:selectedRow forComponent:0];
    
    [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) switchChanged : (id) sender {
    
    UISwitch *mySwitch = (UISwitch *)sender;
    BOOL setting = mySwitch.isOn;
    
    if (setting == TRUE) {
        _deficiencyPicker.alpha = 1;
        _deficiencyPicker.showsSelectionIndicator = YES;
        _deficiencyPicker.userInteractionEnabled = YES;
        
        if ([_lblPart.text isEqualToString:@"Wire Rope, Load Chain, Fittings"])
        {
            timesShown=0;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Length:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
        else if ([_lblPart.text isEqualToString:@"Hoist Load Brake"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Type" message:@"What is the type?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            pageSubmitAlertView = NO;
        }
    }
    else {
        _deficiencyPicker.alpha = .5;
        _deficiencyPicker.showsSelectionIndicator = NO;
        _deficiencyPicker.userInteractionEnabled = NO;
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
                    if ([_lblPart.text isEqualToString:@"Control Station Markings"])
                    {
                        _txtNotes.text = [NSString stringWithFormat:@"%@ %@", _txtNotes.text, textField.text];
                    }
                    else if (timesShown==0&&_optionLocation==22)
                    {
                        timesShown++;
                        _txtNotes.text = [NSString stringWithFormat:@"Length: %@ - %@",textField.text, _txtNotes.text];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Size:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==1&&_optionLocation==22)
                    {
                        timesShown++;
                        _txtNotes.text = [NSString stringWithFormat:@"Size: %@ - %@",textField.text, _txtNotes.text];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Fittings:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                        [alert show];
                        pageSubmitAlertView = NO;
                    }
                    else if (timesShown==2&&_optionLocation==22)
                    {
                        timesShown++;
                        _txtNotes.text = [NSString stringWithFormat:@"Fittings: %@ - %@",textField.text, _txtNotes.text];
                        pageSubmitAlertView = NO;
                    }
                    else if (![textField.text isEqualToString:@""])
                    {
                        _txtNotes.text = [NSString stringWithFormat:@"%@ - %@",textField.text, _txtNotes.text];
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
                                    _createCertificateButton.enabled = TRUE;
                                }
                                else {
                                    _createCertificateButton.enabled = FALSE;

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
                            
                            _createCertificateButton.enabled = TRUE;
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
//The Master View Controller displaying the parts is displayed by being pushed onto the stack.
- (IBAction)showPartsController:(id)sender {
    //Create the Master View Controller.  The Level is the current type of data that's being displayed, and the search value is the value that will be searched
    //in Mongo to reveal the correct information.
    MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:PART_NAME SearchValue:inspection.crane.type];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void) nextPressed {
    if (_optionLocation < [_partsArray count] - 1) {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [self pickerView: _deficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        _optionLocation = _optionLocation + 1;
        [self fillOptionArrays:_partsArray[_optionLocation]];
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:itemListStore];
    }
}
- (void) previousPressed {
    if (_optionLocation > 0) {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[_deficiencyPicker delegate] pickerView:_deficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        _optionLocation = _optionLocation - 1;
        [self fillOptionArrays:_partsArray[_optionLocation]];
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:itemListStore];
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

    [itemListStore setCondition:_optionLocation Condition : myCondition];
    myCondition = nil;
}

#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *) pickerView {
    return 1;
}
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_pickerData count];
}
#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_pickerData objectAtIndex:row];
}

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0f;
}

- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //Get the label from the view.
    UILabel *label = (UILabel *) view;
    
    if (!label)
    {
        //Create the label with the width equal to that of the picker view, and then set the alignment to center, so that the picker view looks
        //like the default iOS 7 picker view.
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 30) ];
        [label setTextAlignment:NSTextAlignmentCenter];
        //Set the font of the label to 12.0f
        [label setFont:[UIFont systemFontOfSize:16.0f]];
    }
    
    label.text = [_pickerData objectAtIndex:row];
    
    return label;
}

- (void) selectedOption : (NSString *) selection
{
    //If the item is contained in the picker, than we go straight to that in the picker.
    if ([_deficiencyPickerArray containsObject:selection])
    {
        [_deficiencyPicker selectRow:[_deficiencyPickerArray indexOfObject:selection] inComponent:0 animated:YES];
    }
}

- (void) selectedPart:(Part *)currentPart
{
    //If the view controller has already been loaded then we continue to save the information on the current page.
    if (_txtNotes != nil)
    {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[_deficiencyPicker delegate] pickerView: _deficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        
        //We need to get the parts that are unique to this particular crane.
        Parts *parts = [[Parts alloc] init:_craneType];
        
        //Get the actual array itself from the parts object
        _partsArray = [parts myParts];
        
        //Get the options that are unique to this particular part.
        [self fillOptionArrays:_partsArray[_optionLocation]];
        
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:itemListStore];
    }
}
//This method gets the view controller that will display the UIDocumentInteractionController preview
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


@end
