//
//  MasterViewController.h
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import <UIKit/UIKit.h>
#import "PartSelectionDelegate.h"
#import "IAConstants.h"

@interface MasterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *level;
    NSDictionary *inspectionCriteria;
    NSArray *results;
    NSString *searchValue;
}

@property (nonatomic, assign) id<PartSelectionDelegate> delegate;
@property (strong, nonatomic) NSArray *tableData;

- (id)initWithStyle : (UITableViewStyle)style
              Level : (NSString *) currentLevel
        SearchValue : (NSArray *) tableData;

@end
