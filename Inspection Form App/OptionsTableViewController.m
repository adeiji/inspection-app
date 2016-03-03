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

int const SEND_INSPECTIONS_INDEX = 0;
int const VIEW_INSPECTIONS_INDEX = 1;

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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsTableViewController *optionsTableViewController = [[OptionsTableViewController alloc] init];
    
    // Is the user currently looking at the available options
    if (_options != nil) {
        if (indexPath.row == SEND_INSPECTIONS_INDEX) {
            optionsTableViewController.inspections = [[IACraneInspectionDetailsManager sharedManager] getAllCranesWithInspections];
            //If there are no cranes that have been inspected on this device than inform the user otherwise show the inspected cranes
            if (optionsTableViewController.inspections != nil) {
                [self.navigationController pushViewController:optionsTableViewController animated:true];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Inspections" message:@"You have not made any inspections to share" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
        }
        else if (indexPath.row == VIEW_INSPECTIONS_INDEX) {
            optionsTableViewController.inspectionsSentToCurrentUser = [[IACraneInspectionDetailsManager sharedManager] getAllCranesForCurrentUserFromServer];
            [self.navigationController pushViewController:optionsTableViewController animated:true];
        }
    }
    else if (_inspections != nil) { // Is the user currently looking at inspections that the current user has done
        optionsTableViewController.selectedCrane = [_inspections objectAtIndex:indexPath.row];
        optionsTableViewController.users = [[[DELoginManager alloc] init] getAllUsers];
        [self.navigationController pushViewController:optionsTableViewController animated:true];
    }
    else if (_users != nil) { // Is the user currently looking at all the users on the server
        PFUser *user = [_users objectAtIndex:indexPath.row];
        [[IACraneInspectionDetailsManager sharedManager] shareCraneDetails:_selectedCrane WithUser:user];
    }
    else if (_inspectionsSentToCurrentUser != nil) {
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
        ViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
        PFCrane *craneObject = [_inspectionsSentToCurrentUser objectAtIndex:indexPath.row];
        InspectedCrane *inspectedCrane = [craneObject getCoreDataObject];
        [self showInspectionScreen:inspectedCrane];
        [viewController.inspectionViewController.itemListStore loadConditionsForCrane:inspectedCrane];
        [[IACraneInspectionDetailsManager sharedManager] deleteEarlierInspectionOfCraneFromServer:inspectedCrane ForUser:[PFUser currentUser]];
    }
}

- (void) showInspectionScreen : (InspectedCrane *) inspectedCrane {
    NSArray *inspectionCranes = [[IACraneInspectionDetailsManager sharedManager] getInspectionCraneOfType:inspectedCrane.type];
    if ([inspectionCranes count] != 0)
    {
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:0] ;
        InspectionCrane *inspectionCrane = inspectionCranes[0];
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:@"options" SearchValue:[inspectionCrane.inspectionPoints array]];
        [navigationController pushViewController:mvc animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HOISTSRL_SELECTED object:nil userInfo:@{ kSelectedInspectedCrane : inspectedCrane }];
        
        ViewController *mainPageViewController = [self.navigationController.viewControllers objectAtIndex:0];
        [mainPageViewController resetInspectionWithCrane:inspectionCrane];
        mvc.delegate = mainPageViewController.inspectionViewController;
        //Push the InspectionViewController ontop of the stack.
        if (![mainPageViewController.navigationController.viewControllers containsObject:mainPageViewController.inspectionViewController])
        {
            [mainPageViewController setIsCraneSet:true];
            [mainPageViewController storeInformationAndDisplayInspectionViewWithCrane:inspectionCrane SelectedRow:nil];
        }
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
