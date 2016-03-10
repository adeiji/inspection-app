//
//  MainPageTableViewController.m
//  Inspection Form App
//
//  Created by adeiji on 3/9/16.
//
//

#import "MainPageTableViewController.h"

@interface MainPageTableViewController ()

@end

@implementation MainPageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cranes = [[IACraneInspectionDetailsManager sharedManager] cranes];
    [_tableView setSeparatorColor:[UIColor clearColor]];
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
    return @"Crane Types";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_cranes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row % 2 == 0 || indexPath.row == 0) {
        [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0]];
    }
    
    InspectionCrane *crane = [_cranes objectAtIndex:indexPath.row];
    cell.textLabel.text = crane.name;
    
    return cell;
}

#pragma mark - Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *viewController = [[UIStoryboard storyboardWithName:@"iPadMainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"customerInfoViewController"];
    [self.navigationController pushViewController:viewController animated:true];
}

@end
