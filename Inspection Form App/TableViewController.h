//
//  TableViewController.h
//  Inspection Form App
//
//  Created by Developer on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *myArray;
@property int myIndex;

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setMyArray:(NSMutableArray *)myArray;

@end
