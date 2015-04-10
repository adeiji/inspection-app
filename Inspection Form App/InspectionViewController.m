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
#import "InspectedCrane.h"
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
    

    inspection = [InspectionManager sharedManager].inspection;
    
    //[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initiateParts];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SwipeDetected" object:self userInfo:@{  USER_INFO_SELECTED_INSPECTION_POINT : _partsArray[_optionLocation] }];

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
    
    InspectionPoint *point = [myPartsArray objectAtIndex:_optionLocation];
    NSString* myPartNumber = [NSString stringWithFormat:@"Part #%d", myOptionLocation + 1];
    
    [_lblPart setText:point.name];
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
    
    if ([point.prompts count] > 0) {
        [[IACraneInspectionDetailsManager sharedManager] getPromptsFromInspectionPoint:point];
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

- (void ) applicableSwitchChanged : (id)sender {
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

- (void) fillOptionArrays : (InspectionPoint *) currentPart {
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
    InspectionCrane *selectedCrane = [[IACraneInspectionDetailsManager sharedManager] crane];
    _partsArray = [selectedCrane.inspectionPoints allObjects];    //Get the actual array itself from the parts object
    [self fillOptionArrays:_partsArray[_optionLocation]];     //Get the options that are unique to this particular part.
    itemListStore = [[ItemListConditionStorage alloc] init:[_partsArray mutableCopy]];       /*Create the itemListStore which will
                                                                                  store all the conditions as they are set.*/
    [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:itemListStore];
    [self changePickerArray:_deficiencyPickerArray];    //Send the array that contains the particular deficiencies unique to this part
    inspectionComplete = NO;
}

- (IBAction)createCertificateButtonPressed:(id)sender {
    [PDFGenerator createCertificate:inspection];
    UIDocumentInteractionController *pdfViewController = [PDFGenerator displayCertificate:inspection];
    pdfViewController.delegate = self;
    [pdfViewController presentPreviewAnimated:NO];

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
        // Save everything that has been created
        [((AppDelegate *) [[UIApplication sharedApplication] delegate]) saveContext];
    }
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

- (void) getLengthFromTextField : (UITextField *) textField {
    timesShown++;
    _txtNotes.text = [NSString stringWithFormat:@"Length: %@ - %@",textField.text, _txtNotes.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Size:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    pageSubmitAlertView = NO;
}

- (void) getSizeFromTextField : (UITextField *) textField {
    timesShown++;
    _txtNotes.text = [NSString stringWithFormat:@"Size: %@ - %@",textField.text, _txtNotes.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Length, size, fittings" message:@"Enter the Fittings:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
    pageSubmitAlertView = NO;
}

- (void) getFittingsFromTextField : (UITextField *) textField {
    timesShown++;
    _txtNotes.text = [NSString stringWithFormat:@"Fittings: %@ - %@",textField.text, _txtNotes.text];
    pageSubmitAlertView = NO;
}

- (void) getSizeFittingsLengthWithTextField : (UITextField *) textField {
    if ([_lblPart.text isEqualToString:@"Control Station Markings"])
    {
        _txtNotes.text = [NSString stringWithFormat:@"%@ %@", _txtNotes.text, textField.text];
    }
    else if (timesShown==0&&_optionLocation==22)
    {
        [self getLengthFromTextField:textField];
    }
    else if (timesShown==1&&_optionLocation==22)
    {
        [self getSizeFromTextField:textField];
    }
    else if (timesShown==2&&_optionLocation==22)
    {
        [self getFittingsFromTextField:textField];
    }
    else if (![textField.text isEqualToString:@""])
    {
        _txtNotes.text = [NSString stringWithFormat:@"%@ - %@",textField.text, _txtNotes.text];
        NSLog(@"text:[%@]", textField.text);
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You must enter a value" message:@"A value must be entered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }
}

- (void) getOverallRatingAndShowPDFWithTextField : (UITextField *) textField {
    
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


- (void) getFinalNecessaryAttributesWithTextField : (UITextField *) textField {
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

#pragma mark - Alert View Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex!=0 || loadRatings == YES || remarksLimitations == YES || finished == YES || proofLoad == YES) || (buttonIndex == 1 && testLoad == YES))
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        //if this is not the alert box that opens when you submit the final page
        if (pageSubmitAlertView==NO)
        {
            [self getSizeFittingsLengthWithTextField:textField];
        }
        //if this is the alertbox for when you submit the form
        else {
            //first we check to see if we are at the testLoad box
            if (loadRatings == NO && testLoad == NO && remarksLimitations == NO && finished == NO && proofLoad == NO)
            {
                //check to see if this is a number
                if ([[NSScanner scannerWithString:textField.text] scanFloat:NULL])
                {
                    [self getOverallRatingAndShowPDFWithTextField:textField];
                }
                else {//if the overall rating was inputed as greater then 5 or less than 1, or if it was not an integer
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Input" message:@"You must enter a number between 1 and 5" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    overallRating = @"";
                }
            }
            else {//here is where we start displaying the Alert Boxes which will ask questions about for the Certficate
                [self getFinalNecessaryAttributesWithTextField:textField];
            }
            
            if (pageSubmitAlertView==YES && testLoad == YES) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applied Test Loads" message:@"Test Loads Applied" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alert show];
                proofLoad = YES;
                testLoad = NO;
            }
        }
    }//if the cancel button is pressed and we are in the midst of asking the questions for the certificate
    else if (buttonIndex ==0 && testLoad == false)
    {
        return;
    }
    else
    {
        testLoad = NO;
        [PDFGenerator DisplayPDFWithOverallRating:inspection];
    }
    
    _createCertificateButton.enabled = YES;
    _createCertificateButton.hidden = NO;
}

#pragma mark - Outlet methods

- (IBAction)gotoCustomerInformation : (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext] rollback];
    // Notify the app that the user is going back to the customer info page
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOTO_CUSTOMER_INFO_PRESSED object:nil];
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
    
    InspectionOption *option = [_pickerData objectAtIndex:row];
    label.text = option.name;
    
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

- (void) selectedPart:(InspectionPoint *) currentPart
{
    //If the view controller has already been loaded then we continue to save the information on the current page.
    if (_txtNotes != nil)
    {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = [[_deficiencyPicker delegate] pickerView: _deficiencyPicker titleForRow:selectedRow forComponent:0];
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        [self fillOptionArrays:currentPart];
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
