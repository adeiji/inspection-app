//
//  OptionsTableViewController.h
//  Inspection Form App
//
//  Created by adeiji on 2/24/16.
//
//

#import <UIKit/UIKit.h>
#import "InspectionsViewController.h"
#import "IACraneInspectionDetailsManager.h"
#import "InspectedCrane.h"
#import "DELoginManager.h"
#import "PFInspectionDetails.h"

@interface OptionsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSArray *inspections;
@property (strong, nonatomic) InspectedCrane *selectedCrane;


@end