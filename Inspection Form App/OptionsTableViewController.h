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
#import "MasterViewController.h"
#import "AccountTableViewController.h"
#import "IAAddSignatureViewController.h"
#import "IAAddSignatureView.h"

@interface OptionsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSArray *inspections;
@property (strong, nonatomic) NSArray *inspectionsSentToCurrentUser;
@property (strong, nonatomic) InspectedCrane *selectedCrane;
@property (nonatomic, assign) id<PartSelectionDelegate> delegate;

@end
