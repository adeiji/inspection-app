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
    
    cell.textLabel.text = [dataToShow objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:20.0f]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsTableViewController *optionsTableViewController = [[OptionsTableViewController alloc] init];
    
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
            
        }
    }
    else if (_inspections != nil) {
        optionsTableViewController.selectedCrane = [_inspections objectAtIndex:indexPath.row];
        optionsTableViewController.users = [[[DELoginManager alloc] init] getAllUsers];
        [self.navigationController pushViewController:optionsTableViewController animated:true];
    }
    else if (_users != nil) {
        PFUser *user = [_users objectAtIndex:indexPath.row];
        [[IACraneInspectionDetailsManager sharedManager] shareCraneDetails:_selectedCrane WithUser:user];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
