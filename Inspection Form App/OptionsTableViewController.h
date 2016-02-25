//
//  OptionsTableViewController.h
//  Inspection Form App
//
//  Created by adeiji on 2/24/16.
//
//

#import <UIKit/UIKit.h>
#import "InspectionsViewController.h"

@interface OptionsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *options;

@end
