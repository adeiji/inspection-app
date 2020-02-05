//
//  AccountTableViewController.m
//  Inspection Form App
//
//  Created by adeiji on 3/4/16.
//
//

#import "AccountTableViewController.h"
#import "Inspection_Form_App-Swift.h"

@interface AccountTableViewController ()

@end

NSString *const LOGIN = @"Login With Another Account", *LOGOUT = @"Logout", *EDIT_USERNAME = @"Edit Username";

@implementation AccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _options = [NSMutableArray arrayWithObject:LOGIN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Account";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [_options objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_options objectAtIndex:indexPath.row] isEqualToString:LOGIN]) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
        [self.navigationController pushViewController:loginViewController animated:true];
    }
    else if ([[_options objectAtIndex:indexPath.row] isEqualToString:LOGOUT]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are You Sure You Want to Logout?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [UtilityFunctions removeUser];
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
            [self.navigationController pushViewController:loginViewController animated:true];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:logoutAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:true completion:nil];
    }
}
@end
