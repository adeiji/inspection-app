//
//  MasterViewController.h
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

typedef enum {
    TYPE_NAME,
    PART_NAME,
    OPTIONS
} TableLevel;

@end