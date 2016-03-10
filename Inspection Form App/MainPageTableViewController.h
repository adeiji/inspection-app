//
//  MainPageTableViewController.h
//  Inspection Form App
//
//  Created by adeiji on 3/9/16.
//
//

#import <UIKit/UIKit.h>
#import "IACraneInspectionDetailsManager.h"

@interface MainPageTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *cranes;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
