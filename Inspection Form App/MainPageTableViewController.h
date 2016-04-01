//
//  MainPageTableViewController.h
//  Inspection Form App
//
//  Created by adeiji on 3/9/16.
//
//

#import <UIKit/UIKit.h>
#import "IACraneInspectionDetailsManager.h"
#import "SyncManager.h"
#import "IAConstants.h"

@interface MainPageTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *cranes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)downloadInspectionDetailsButtonPressed:(id)sender;

@end
