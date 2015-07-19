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
#import <Masonry/Masonry.h>

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
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    inspection = [InspectionManager sharedManager].inspection;
    InspectionCrane *selectedCrane = [[IACraneInspectionDetailsManager sharedManager] crane];
    _partsArray = [selectedCrane.inspectionPoints array];                                    /*Get the actual array itself from the parts object*/
    [self fillOptionArrays:_partsArray[_optionLocation]];                                    /*Get the options that are unique to this particular part.*/
    [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:_itemListStore];
    [self changePickerArray:_deficiencyPickerArray];    //Send the array that contains the particular deficiencies unique to this part
    inspectionComplete = NO;

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
    if (myOptionLocation < [myItemListStore.myConditions count]) {
        myCondition = [myItemListStore.myConditions objectAtIndex:myOptionLocation];
    }
    else {
        [myItemListStore.myConditions addObject:myCondition];
    }
    
    _txtNotes.text = myCondition.notes;
    
    InspectionPoint *point = [myPartsArray objectAtIndex:_optionLocation];
    NSString* myPartNumber = [NSString stringWithFormat:@"Part #%d", myOptionLocation + 1];
    
    [_lblPart setText:point.name];
    [_lblPartNumber setText:myPartNumber];
    [_deficiencyPicker selectRow:myCondition.pickerSelection inComponent:0 animated:YES];
    [_deficiencySwitch setOn:myCondition.deficient];
    [_applicableSwitch setOn:myCondition.applicable];
    [self promptCancelPressed:nil];
    if ([point.prompts count] > 0) {

        [self displayPromptViewWithPrompts:[point.prompts array]];
        promptView.promptLocation = 0;
        Prompt *prompt = promptView.prompts[promptView.promptLocation];
        promptView.lblPromptText.text = prompt.title;
    }
    
    [self setDeficiencyViews];
}

- (void) displayPromptViewWithPrompts : (NSArray *) prompts {
    promptView = [[[NSBundle mainBundle] loadNibNamed:@"PromptView" owner:self options:nil] firstObject];
    [[promptView layer] setCornerRadius:25.0f];
    [[promptView layer] setBorderWidth:2.0f];
    [[promptView layer] setBorderColor:[UIColor colorWithRed:0.0f green:172.0f/255.0f blue:238.0f/255.0f alpha:1.0].CGColor];
    promptView.prompts = prompts;
    [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_SHOWN object:nil];
    [self.view setUserInteractionEnabled:NO];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:promptView];
    [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo([[[UIApplication sharedApplication] delegate] window]);
        make.centerY.equalTo([[[UIApplication sharedApplication] delegate] window]).with.offset(-200);

        make.width.equalTo(@385);
        make.height.equalTo(@249);
    }];
    
    [promptView.txtPromptResult becomeFirstResponder];
    promptView.txtPromptResult.placeholder = @"Please enter a value, or click cancel";
}


- (IBAction)promptOkPressed:(id)sender {
    
    if (![promptView.txtPromptResult.text isEqualToString:@""])
    {
        _txtNotes.text = [NSString stringWithFormat:@"%@ %@ - %@\n", _txtNotes.text, promptView.lblPromptText.text ,promptView.txtPromptResult.text];
        
        if (promptView.promptLocation < [promptView.prompts count] - 1) {
            promptView.promptLocation ++;
            Prompt *prompt = promptView.prompts[promptView.promptLocation];
            promptView.lblPromptText.text = prompt.title;
            [self.view setUserInteractionEnabled:NO];
        }
        else {
            [promptView removeFromSuperview];
            promptView = nil;
            [self.view setUserInteractionEnabled:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_HIDDEN object:nil];
        }
    }
    else
    {
        promptView.txtPromptResult.placeholder = @"Please enter a value, or click cancel";
    }
    
    promptView.txtPromptResult.text = @"";
}

- (IBAction)promptCancelPressed:(id)sender {
    if ((promptView.promptLocation < [promptView.prompts count] - 1) && promptView != nil) {
        promptView.promptLocation ++;
        Prompt *prompt = promptView.prompts[promptView.promptLocation];
        promptView.lblPromptText.text = prompt.title;
        [self.view setUserInteractionEnabled:NO];
    }
    else {
        [promptView removeFromSuperview];
        promptView = nil;
        [self.view setUserInteractionEnabled:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_HIDDEN object:nil];
    }
    
    promptView.txtPromptResult.text = @"";
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
    _partsArray = [selectedCrane.inspectionPoints array];                                    /*Get the actual array itself from the parts object*/
    [self fillOptionArrays:_partsArray[_optionLocation]];                                    /*Get the options that are unique to this particular part.*/
    _itemListStore = [[ItemListConditionStorage alloc] init:[_partsArray mutableCopy]];       /*Create the itemListStore which will 
                                                                                              store all the conditions as they are set.*/
    [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:_itemListStore];
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

    NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
    InspectionOption *option = [_pickerData objectAtIndex:selectedRow];
    NSString *myDeficientPart = option.name;
    [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];

    if (inspection.inspectedCrane.hoistSrl)
    {
        [[IACraneInspectionDetailsManager sharedManager] saveAllConditionsForCrane:inspection.inspectedCrane
                                                                    Conditions:_itemListStore.myConditions];
    }
    //If all the information is correctly inputed on the page, then we simply save the information.  Otherwise we go back so that the user can change whatever is necessary.
    if ([self validate]) {
        
        inspection.itemList = _itemListStore;
        
        //if all the fields entered pass then, the the customer information is inserted and all the data is saved into a table
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        NSString *myDeficientPart = ((InspectionOption *)[[_deficiencyPicker delegate]
                                     pickerView:_deficiencyPicker
                                     titleForRow:selectedRow
                                     forComponent:0]).name;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Overall Rating"
                              message:@"What is the overall condition rating?"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"ok", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        [alert becomeFirstResponder];
        
        pageSubmitAlertView = YES;
        
        //Save the status of this page so that when going back to it we can view it as we left it
        [self saveInfo : _txtNotes.text
                       : _deficiencySwitch.on
                       : [_deficiencyPicker selectedRowInComponent:0]
                       : myDeficientPart:_applicableSwitch.on];
        
        inspectionComplete = YES;
        myDeficientPart = nil;
        loadRatings = NO;
        proofLoadDescription = NO;
        testLoad = NO;
        remarksLimitations = NO;

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
            [alert becomeFirstResponder];
            pageSubmitAlertView = NO;
        }
        else if ([_lblPart.text isEqualToString:@"Hoist Load Brake"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Type" message:@"What is the type?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
            [alert becomeFirstResponder];
            pageSubmitAlertView = NO;
        }
    }
    else {
        _deficiencyPicker.alpha = .5;
        _deficiencyPicker.showsSelectionIndicator = NO;
        _deficiencyPicker.userInteractionEnabled = NO;
    }
    
}

- (void) getOverallRatingAndShowPDFWithTextField : (UITextField *) textField {
    
    if (([textField.text intValue]<0 || [textField.text intValue]>5) && (loadRatings == NO && testLoad == NO && remarksLimitations == NO && finished == NO && proofLoad == NO))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Input" message:@"You must enter a number between 1 and 5" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert becomeFirstResponder];
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
            [alert becomeFirstResponder];
            testLoad = YES;
            _createCertificateButton.enabled = TRUE;
        }
        else {
            _createCertificateButton.enabled = FALSE;
            [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:_partsArray];
            UIDocumentInteractionController *pdfViewController = [PDFGenerator DisplayPDFWithOverallRating:inspection];
            pdfViewController.delegate = self;
            [pdfViewController presentPreviewAnimated:NO];
            // Save everything that has been created
        }
    }
}


- (void) getFinalNecessaryAttributesWithTextField : (UITextField *) textField {
    if (proofLoad == YES)
    {
//        testLoad = textField.text;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Proof Load Description" message:@"Description of Proof Load" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        [alert becomeFirstResponder];
        loadRatings = YES;
        proofLoad = NO;
        testLoad = textField.text;
        inspection.testLoad = textField.text;
    }
    else if (loadRatings == YES)
    {
        proofLoadDescription = textField.text;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Ratings" message:@"Basis for assigned load ratings" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        [alert becomeFirstResponder];
        remarksLimitations = YES;
        loadRatings = NO;
        inspection.proofLoad = textField.text;

    }
    else if (remarksLimitations == YES)
    {
        loadRatings = textField.text;
        UIAlertView *alert;
        if (![_craneType isEqualToString:ELECTRIC_HOIST])
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Remarks Limitations" message:@"Remarks and/or Limitations Imposed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:@"Slip Test" message:@"What did Hoist Slip At?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        }
        
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
        [alert becomeFirstResponder];
        remarksLimitations = NO;
        finished = YES;
        inspection.loadRatings = textField.text;
    }
    else if (finished == YES)
    {
        remarksLimitations = textField.text;
        inspection.remarksLimitations = textField.text;
        finished = NO;
        [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:_partsArray];
        UIDocumentInteractionController *pdfViewController = [PDFGenerator DisplayPDFWithOverallRating:inspection];
        pdfViewController.delegate = self;
        [pdfViewController presentPreviewAnimated:NO];
        // Save everything that has been created
        
        _createCertificateButton.enabled = TRUE;
    }
}

#pragma mark - Alert View Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex!=0 || loadRatings == YES || remarksLimitations == YES || finished == YES || proofLoad == YES) || (buttonIndex == 1 && testLoad == YES))
    {
        UITextField *textField;
        if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
        {
            textField = [alertView textFieldAtIndex:0];
        }
        //if this is the alertbox for when you submit the form
        if (pageSubmitAlertView == YES) {
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
                    [alert becomeFirstResponder];
                    overallRating = @"";
                }
            }
            else if (pageSubmitAlertView==YES && testLoad == YES) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Applied Test Loads" message:@"Test Loads Applied" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alert show];
                [alert becomeFirstResponder];
                proofLoad = YES;
                testLoad = NO;
            }

            else {//here is where we start displaying the Alert Boxes which will ask questions about for the Certficate
                [self getFinalNecessaryAttributesWithTextField:textField];
            }
            
                    }
    }//if the cancel button is pressed and we are in the midst of asking the questions for the certificate
    else if (buttonIndex ==0 && testLoad == YES)
    {
        [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:_partsArray];
        UIDocumentInteractionController *pdfViewController = [PDFGenerator DisplayPDFWithOverallRating:inspection];
        pdfViewController.delegate = self;
        [pdfViewController presentPreviewAnimated:NO];
        // Save everything that has been created
    }
}

#pragma mark - Outlet methods

- (IBAction)gotoCustomerInformation : (id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[((AppDelegate *) [[UIApplication sharedApplication] delegate]) managedObjectContext] rollback];
    // Notify the app that the user is going back to the customer info page
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GOTO_CUSTOMER_INFO_PRESSED object:nil];
    
    NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
    InspectionOption *option = [_pickerData objectAtIndex:selectedRow];
    
    NSString *myDeficientPart = option.name;
    [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
}


- (void) nextPressed {
    if (_optionLocation < [_partsArray count] - 1) {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        InspectionOption *option = [_pickerData objectAtIndex:selectedRow];
        NSString *myDeficientPart = option.name;
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        _optionLocation = _optionLocation + 1;
        [self fillOptionArrays:_partsArray[_optionLocation]];
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:_itemListStore];
    }
}
- (void) previousPressed {
    if (_optionLocation > 0) {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        InspectionOption *option = [_pickerData objectAtIndex:selectedRow];
        NSString *myDeficientPart = option.name;
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart:_applicableSwitch.on];
        _optionLocation = _optionLocation - 1;
        [self fillOptionArrays:_partsArray[_optionLocation]];
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:_itemListStore];
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

    [_itemListStore setCondition:_optionLocation Condition : myCondition];
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
    newOptionLocation:(NSInteger)optionLocation
{
    //If the view controller has already been loaded then we continue to save the information on the current page.
    if (_txtNotes != nil)
    {
        NSUInteger selectedRow = [_deficiencyPicker selectedRowInComponent:0];
        InspectionOption *myDeficientPart = [_pickerData objectAtIndex:selectedRow];
        [self saveInfo:_txtNotes.text :_deficiencySwitch.on:[_deficiencyPicker selectedRowInComponent:0]:myDeficientPart.name:_applicableSwitch.on];
        _optionLocation = optionLocation;
        [self fillOptionArrays:currentPart];
        [self changePickerArray:_deficiencyPickerArray];
        [self changeLayout:_optionLocation PartsArray:_partsArray ItemListStore:_itemListStore];
    }
}
//This method gets the view controller that will display the UIDocumentInteractionController preview
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}


@end
