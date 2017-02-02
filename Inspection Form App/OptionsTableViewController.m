//
//  OptionsTableViewController.m
//  Inspection Form App
//
//  Created by adeiji on 2/24/16.
//
//

#import "OptionsTableViewController.h"


@interface OptionsTableViewController ()

@end

// These are the indexes of Strings stored in the options array which stores the options that are viewed on the table view controller, you can update the actual strings themselves in the ViewController.m file in the method showOptionsMenu
int const SEND_INSPECTIONS_INDEX = 0, VIEW_INSPECTIONS_INDEX = 1, ACCOUNT_INDEX = 2, ADD_SIGNATURE_INDEX = 3, BACKUP_TO_CLOUD = 4, LOAD_WATER_DISTRICT_CRANES = 5;

@implementation OptionsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Options"];
    [self.navigationController setNavigationBarHidden:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_inspections != nil) {
        return [_inspections count];
    }
    else if (_users != nil) {
        return [_users count];
    }
    else if (_inspectionsSentToCurrentUser != nil) {
        return [_inspectionsSentToCurrentUser count];
    }
    
    return [_options count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    NSArray *dataToShow;
    
    if (_inspections != nil) {
        InspectedCrane *crane = [_inspections objectAtIndex:indexPath.row];
        cell.textLabel.text = crane.hoistSrl;
        return cell;
    }
    else if (_users != nil) {
        PFUser *user = [_users objectAtIndex:indexPath.row];
        cell.textLabel.text = user.username;
        return cell;
    }
    else if (_options != nil) {
        dataToShow = _options;
    }
    else if (_inspectionsSentToCurrentUser != nil) {
        InspectedCrane *inspectedCrane = [_inspectionsSentToCurrentUser objectAtIndex:indexPath.row];
        cell.textLabel.text = inspectedCrane.hoistSrl;
        
        return cell;
    }
    
    cell.textLabel.text = [dataToShow objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:20.0f]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (void) handleSendInspectionsSelectedWithTableViewController : (OptionsTableViewController *) optionsTableViewController {
    optionsTableViewController.inspections = [[IACraneInspectionDetailsManager sharedManager] getAllCranesWithInspections];
    //If there are no cranes that have been inspected on this device than inform the user otherwise show the inspected cranes
    if (optionsTableViewController.inspections != nil) {
        [self.navigationController pushViewController:optionsTableViewController animated:true];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Inspections" message:@"You have not made any inspections to share" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okayAction];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsTableViewController *optionsTableViewController = [[OptionsTableViewController alloc] init];
    
    // Is the user currently looking at the available options
    if (_options != nil) {
        if (indexPath.row == SEND_INSPECTIONS_INDEX) {
            [self handleSendInspectionsSelectedWithTableViewController:optionsTableViewController];
        }
        else if (indexPath.row == VIEW_INSPECTIONS_INDEX) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                optionsTableViewController.inspectionsSentToCurrentUser = [[IACraneInspectionDetailsManager sharedManager] getAllCranesForCurrentUserFromServer];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:optionsTableViewController animated:true];
                });
            });
        }
        else if (indexPath.row == ACCOUNT_INDEX) {
            AccountTableViewController *accountTableViewController = [AccountTableViewController new];
            [self.navigationController pushViewController:accountTableViewController animated:true];
        }
        else if (indexPath.row == ADD_SIGNATURE_INDEX) {
            // Change the device orientation to portrait
            NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            
            IAAddSignatureViewController *signatureViewController = [[IAAddSignatureViewController alloc] init];
            signatureViewController.signatureView = [[IAAddSignatureView alloc] initWithFrame:signatureViewController.view.frame];
            [self.navigationController pushViewController:signatureViewController animated:true];
            [signatureViewController.view addSubview:signatureViewController.signatureView];
            signatureViewController.signatureView.backgroundColor = [UIColor whiteColor];
        }
        else if (indexPath.row == BACKUP_TO_CLOUD) {
            [[IACraneInspectionDetailsManager sharedManager] backupCranesOnDevice];
        }
        else if (indexPath.row == LOAD_WATER_DISTRICT_CRANES) {
            [[IACraneInspectionDetailsManager sharedManager]  saveAllWaterDistrictCranes];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Loading Finished" message:@"Finished Loading LVWWD Cranes" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okayAction];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }
    else if (_inspections != nil) { // Is the user currently looking at inspections that the current user has done
        optionsTableViewController.selectedCrane = [_inspections objectAtIndex:indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            optionsTableViewController.users = [[[DELoginManager alloc] init] getAllUsers];
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.navigationController pushViewController:optionsTableViewController animated:true];     
            });
        });
    }
    else if (_users != nil) { // Is the user currently looking at all the users on the server
        PFUser *user = [_users objectAtIndex:indexPath.row];
        [[IACraneInspectionDetailsManager sharedManager] shareCraneDetails:_selectedCrane WithUser:user WithViewControllerOrNilToDisplayAlert:self] ;
    }
    else if (_inspectionsSentToCurrentUser != nil) {
        PFCrane *craneObject = [_inspectionsSentToCurrentUser objectAtIndex:indexPath.row];
        [self handleDownloadedCraneWithCraneObject:craneObject];
    }
}

- (void) handleDownloadedCraneWithCraneObject : (PFCrane *) craneObject {
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
    
    InspectedCrane *inspectedCrane = [craneObject getCoreDataObjectWithContextOrNil:nil];
    
    [self showInspectionScreen:inspectedCrane];
    [viewController.inspectionViewController.itemListStore loadConditionsForCrane:inspectedCrane];
    [viewController.inspectionViewController.itemListStore loadConditionsForCraneFromServer:craneObject WithInspectedCrane:inspectedCrane];
    
    // If we send a NIL object from FromUser it's because this object was shared by another device, and the owner of that device does not need to be known.  Only information that was backed up from a device will contain data for FromUser key
    [[IACraneInspectionDetailsManager sharedManager] deleteEarlierInspectionOfCraneFromServer:inspectedCrane ForUser:[PFUser currentUser] ];
    [[IACraneInspectionDetailsManager sharedManager] removeAllConditionsForCrane:inspectedCrane];
    
}

- (void) showInspectionScreen : (InspectedCrane *) inspectedCrane {
    NSArray *inspectionCranes = [[IACraneInspectionDetailsManager sharedManager] getInspectionCraneOfType:inspectedCrane.type];
    if ([inspectionCranes count] != 0)
    {
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:0] ;
        InspectionCrane *inspectionCrane = inspectionCranes[0];
        
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain Level:@"partName" SearchValue:[inspectionCrane.inspectionPoints array]];
        [navigationController pushViewController:mvc animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HOISTSRL_SELECTED object:nil userInfo:@{ kSelectedInspectedCrane : inspectedCrane }];
        
        ViewController *mainPageViewController = [self.navigationController.viewControllers objectAtIndex:0];
        [mainPageViewController resetInspectionWithCrane:inspectionCrane];
        mvc.delegate = mainPageViewController.inspectionViewController;
        
        //Push the InspectionViewController ontop of the stack.
        if (![mainPageViewController.navigationController.viewControllers containsObject:mainPageViewController.inspectionViewController])
        {
            [mainPageViewController setIsCraneSet:true];
            [mainPageViewController.navigationController popToRootViewControllerAnimated:false];
            [mainPageViewController storeInformationAndDisplayInspectionViewWithCrane:inspectionCrane SelectedRow:0];
        }
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
