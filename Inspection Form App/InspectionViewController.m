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
#import "MasterViewController.h"
#import <Masonry/Masonry.h>

@interface InspectionViewController () {
    UISwipeGestureRecognizer *gestureRecognizerLeft;
    UISwipeGestureRecognizer *gestureRecognizerRight;
}

@end

NSString *const LOAD_RATINGS = @"loadRatings", *REMARKS_LIMITATIONS = @"remarksLimitations", *PROOF_LOAD = @"proofLoad", *TEST_LOAD = @"testLoad";

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
    
    [_applicableSwitch addTarget:self action:@selector(applicableSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    gestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    gestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    gestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
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

- (void) disableSwiping {
    gestureRecognizerLeft.enabled = false;
    gestureRecognizerRight.enabled = false;
}

- (void) enableSwiping {
    gestureRecognizerLeft.enabled = true;
    gestureRecognizerRight.enabled = true;
}

- (void) displayPromptViewWithPrompts : (NSArray *) prompts {
    promptView = [[[NSBundle mainBundle] loadNibNamed:@"PromptView" owner:self options:nil] firstObject];
    [[promptView layer] setCornerRadius:10.0f];
    [[promptView layer] setBorderWidth:1.0f];
    [[promptView layer] setBorderColor:[UIColor colorWithRed:0.0f green:172.0f/255.0f blue:238.0f/255.0f alpha:1.0].CGColor];
    promptView.prompts = prompts;
    [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_SHOWN object:nil];
    [self disableSwiping];
    
    [self.view addSubview:promptView];
    [promptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).with.offset(-200);

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
        }
        else {
            [promptView removeFromSuperview];
            promptView = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_HIDDEN object:nil];
            [self enableSwiping];
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
    }
    else {
        [promptView removeFromSuperview];
        promptView = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:UI_PROMPT_HIDDEN object:nil];
        [self enableSwiping];
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
        
        [self showGetOverallRatingController];
        
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

// prompt the user to get the overall rating of the inspected crane
- (void) showGetOverallRatingController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Overall Rating" message:@"What is the overall condition rating?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setOverallRatingAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *overallRatingTextField = alertController.textFields[0];
        overallRating = overallRatingTextField.text;
        
        if ([overallRatingTextField.text intValue] < 3) {
            [self showTestLoadsPrompt];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Overall Rating";
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([textField.text intValue] > 0 && [textField.text intValue] < 5) {
                setOverallRatingAction.enabled = true;
                NSLog(@"Text Field Update Detected");
            } else if ([textField.text intValue] < 0 || [textField.text intValue] > 5) {
                setOverallRatingAction.enabled = false;
            }
        }];
    }];
    
    setOverallRatingAction.enabled = false;
    [alertController addAction:setOverallRatingAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:true completion:nil];
}

// Prompt the user if this specific inspection is a test loads
- (void) showTestLoadsPrompt {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Test Loads?" message:@"Is This a Test Load?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getTestLoads];
    }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self displayInspectionResultsPDFWithShouldEnableCertificateButton:true];
    }];
    
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:true completion:nil];
}

// Prompt the user to enter the test loads
- (void) getTestLoads {
    [self promptForTestLoadInformationWithTitle:@"Test Loads Applied" Message:@"Enter the test loads applied" Placeholder:@"Enter Test Loads Applied" LoadSection:TEST_LOAD];
}

// Prompt the user to enter the proof loads
- (void) promptForTestLoadInformationWithTitle : (NSString *) title
                                       Message : (NSString *) message
                                   Placeholder : (NSString *) placeholder
                                   LoadSection : (NSString *) loadSection
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
    }];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *proofLoadTextField = alertController.textFields[0];
        if ([loadSection isEqual:PROOF_LOAD]) {
            proofLoad = proofLoadTextField.text;
            inspection.proofLoad = proofLoadTextField.text;
            [self promptForTestLoadInformationWithTitle:@"Load Ratings" Message:@"Basis for assigned load ratings" Placeholder:@"Enter Basis for assigned load ratings" LoadSection:LOAD_RATINGS];
            
        } else if ([loadSection isEqual:TEST_LOAD]) {
            testLoad = proofLoadTextField.text;
            inspection.testLoad = proofLoadTextField.text;
            [self promptForTestLoadInformationWithTitle:@"Proof Load" Message:@"Proof Load Description" Placeholder:@"Enter Proof Load Description" LoadSection:PROOF_LOAD];
        } else if ([loadSection isEqual:LOAD_RATINGS]) {
            loadRatings = proofLoadTextField.text;
            inspection.loadRatings = proofLoadTextField.text;
            if (![_craneType isEqualToString:ELECTRIC_HOIST])
            {
                [self promptForTestLoadInformationWithTitle:@"Remarks Limitations" Message:@"Remarks and/or Limitations Imposed" Placeholder:@"Enter limitations imposed" LoadSection:REMARKS_LIMITATIONS];
            }
            else {
                [self promptForTestLoadInformationWithTitle:@"Slip Test" Message:@"What did hoist Slip At?" Placeholder:@"Hoist slipped at?" LoadSection:REMARKS_LIMITATIONS];
            }
        } else if ([loadSection isEqual:REMARKS_LIMITATIONS]) {
            remarksLimitations = proofLoadTextField.text;
            inspection.remarksLimitations = proofLoadTextField.text;
            [self displayInspectionResultsPDFWithShouldEnableCertificateButton:true];
        }
        
    }];
    
    [alertController addAction:okayAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void) displayInspectionResultsPDFWithShouldEnableCertificateButton : (BOOL) enabled {
    _createCertificateButton.enabled = enabled;
    [PDFGenerator writeReport:inspection.itemList Inspection:inspection OverallRating:overallRating PartsArray:_partsArray];
    UIDocumentInteractionController *pdfViewController = [PDFGenerator DisplayPDFWithOverallRating:inspection];
    pdfViewController.delegate = self;
    [pdfViewController presentPreviewAnimated:NO];
    // Save everything that has been created
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
