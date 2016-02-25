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

NSNumber *const SEND_INSPECTIONS_INDEX = 0;

@implementation OptionsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _options = [NSArray arrayWithObjects:@"Send Inspection", nil];
    [self.navigationItem setTitle:@"Options"];
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
    return [_options count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = [_options objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:20.0f]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SEND_INSPECTIONS_INDEX.intValue) {
        OptionsTableViewController *optionsTableViewController = [[OptionsTableViewController alloc] init];
        [self.navigationController presentViewController:optionsTableViewController animated:true completion:nil];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
