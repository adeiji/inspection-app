//
//  MasterViewController.m
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "Part.h"


@interface MasterViewController ()

@end

@implementation MasterViewController

@synthesize delegate = __delegate;

#define PART_NAME_COL @"partName"
#define TYPE_COL @"type"
#define COLLECTION_NAME @"sswr.inspectioncriterias"
#define PART_COL @"part"
#define OPTIONS_COL @"optionList"
#define OPTIONS_PATH @"type.part.partName"
#define PART_NAME_PATH @"type.typeName"
#define TYPE_NAME_COL @"typeName"
#define COLUMN_CONTAINING_TOP_ELEMENTS @"hoistsrl"

static NSString *const PART_NAME = @"partName";
static NSString *const OPTIONS = @"options";

- (id)initWithStyle : (UITableViewStyle)style
              Level : (NSString *) currentLevel
        SearchValue : (NSArray *) tableData

{
    self = [super initWithStyle:style];
    if (self) {
        level = currentLevel;
        _tableData = tableData;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setObservers];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!level) // If this is the crane list
    {
        _tableData = [[IACraneInspectionDetailsManager sharedManager] getAllInspectedCranes];
        [self.tableView reloadData];
    }
}

- (void) reloadCranes {
    if (!level)
    {
        _tableData = [[IACraneInspectionDetailsManager sharedManager] getAllInspectedCranes];
        [self.tableView reloadData];
    }
    
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
    viewController.btnSync.enabled = YES;
}

- (void) setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePart:) name:@"SwipeDetected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayParts:) name:kInspectionViewControllerPushed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoRootViewController) name:NOTIFICATION_GOTO_CUSTOMER_INFO_PRESSED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promptShown) name:UI_PROMPT_SHOWN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(promptHidden) name:UI_PROMPT_HIDDEN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCranes) name:WATER_DISTRICT_CRANES_SAVED object:nil];
}

- (void) promptShown {
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void) promptHidden {
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        [viewController.navigationItem setHidesBackButton:NO animated:NO];
    }
}

- (void) gotoRootViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setObservers];
    
    if (!level)
    {
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
        [navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification methods

- (void) displayParts : (NSNotification *) notification
{
    NSArray *inspectionPoints = [notification.userInfo[USER_INFO_SELECTED_CRANE_INSPECTION_POINTS] allObjects];
    
    if (level == nil && [self.navigationController.topViewController isEqual:self])
    {
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain Level:PART_NAME SearchValue:inspectionPoints];
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

- (void) changePart : (NSNotification *) notification
{
    if (level == OPTIONS)
    {
        InspectionPoint *inspectionPoint = notification.userInfo[USER_INFO_SELECTED_INSPECTION_POINT];
        _tableData = [inspectionPoint.inspectionOptions array];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableData count];
}

/*
 
 When user presses the load button, than we load the crane conditions for the specific crane
 
 */
- (void) loadCraneConditions : (UIButton *) button {
    
    InspectedCrane *crane = [_tableData objectAtIndex:button.tag];
    
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *viewController = [navigationController.viewControllers objectAtIndex:0];
    [viewController.inspectionViewController.itemListStore loadConditionsForCrane:crane];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HOISTSRL_SELECTED object:nil userInfo:@{ kSelectedInspectedCrane : crane }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
    id obj = [_tableData objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[InspectedCrane class]])
    {
        InspectedCrane *crane = (InspectedCrane *) obj;
        label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, crane.hoistSrl];
        NSArray *conditions = [[IACraneInspectionDetailsManager sharedManager] getAllConditionsForCrane:crane];
        if ([conditions count] > 0)
        {
            UIButton *loadButton = [[UIButton alloc] init];
            [loadButton setFrame:CGRectMake(cell.frame.size.width - 100, 12, 75, 30)];
            [loadButton setTitle:@"Load" forState:UIControlStateNormal];
            [loadButton setBackgroundColor:[UIColor colorWithRed:66.0/255.0f green:188.0/255.0f blue:98.0f/255.0f alpha:1.0f]];
            loadButton.tag = indexPath.row;
            [loadButton addTarget:self action:@selector(loadCraneConditions:) forControlEvents:UIControlEventTouchUpInside];
            [loadButton setShowsTouchWhenHighlighted:YES];
            [cell addSubview:loadButton];
        }
        
        if ([crane.shared isEqualToNumber:[NSNumber numberWithBool:true]]) {
            [cell setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0]];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        NSLog(@"Crane Shared %@", crane.shared.stringValue);
    }
    else {
        id obj = [_tableData objectAtIndex:indexPath.row];
        if ([obj respondsToSelector:@selector(name)]) {
            label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, [obj name]];
        }
    }

    
    [cell addSubview:label];
    
    return cell;
}

- (void) showInspectionPointsForCraneAtIndexPath : (NSIndexPath *) indexPath {
    InspectedCrane *crane = [_tableData objectAtIndex:indexPath.row];
    NSArray *inspectionCranes = [[IACraneInspectionDetailsManager sharedManager] getInspectionCraneOfType:crane.type];
    if ([inspectionCranes count] != 0)
    {
        InspectionCrane *inspectionCrane = inspectionCranes[0];
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain Level:PART_NAME SearchValue:[inspectionCrane.inspectionPoints array]];
        [self.navigationController pushViewController:mvc animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HOISTSRL_SELECTED object:nil userInfo:@{ kSelectedInspectedCrane : crane }];
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
        ViewController *vc = [navigationController.viewControllers objectAtIndex:0];
        [vc resetInspectionWithCrane:inspectionCrane];
    }
}

- (void) handleOptionSelectedAtIndexPath : (NSIndexPath *) indexPath {
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *vc = [navigationController.viewControllers objectAtIndex:0];
    
    //Push the InspectionViewController ontop of the stack.
    if (![vc.navigationController.viewControllers containsObject:vc.inspectionViewController])
    {
        [vc.navigationController pushViewController:vc.inspectionViewController animated:YES];
    }
    //Set the delegate to the InspectionViewController so that all changes are read by the inspection view controlller.
    __delegate = vc.inspectionViewController;
    if (__delegate)
    {
        [__delegate selectedOption:[_tableData objectAtIndex:indexPath.row]];
    }
}

- (void) showOptionsForInspectionPointAtIndexPath : (NSIndexPath *) indexPath {
    InspectionPoint *inspectionPoint = [_tableData objectAtIndex:indexPath.row];
    
    //Create the Master View controller that we will push onto the view controller stack.
    MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain   Level:OPTIONS SearchValue:[inspectionPoint.inspectionOptions array]];
    //Get a reference to the current displayed view controller.
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *mainPageViewController = [navigationController.viewControllers objectAtIndex:0];
    //Push the InspectionViewController ontop of the stack.
    if (![mainPageViewController.navigationController.viewControllers containsObject:mainPageViewController.inspectionViewController])
    {
        [mainPageViewController storeInformationAndDisplayInspectionViewWithCrane:inspectionPoint.inspectionCrane SelectedRow:0];
    }
    
    //Set the delegate to the InspectionViewController so that all changes are read by the inspection view controlller.
    __delegate = mainPageViewController.inspectionViewController;
    
    [self.navigationController pushViewController:mvc animated:YES];
    
    if (__delegate)
    {
        mainPageViewController.inspectionViewController.craneType = inspectionPoint.inspectionCrane.name;
        [__delegate selectedPart:inspectionPoint newOptionLocation:indexPath.row];
        mainPageViewController = nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([level isEqualToString:PART_NAME])
    {
        [self showOptionsForInspectionPointAtIndexPath:indexPath];
    }
    else if ([level isEqualToString:OPTIONS])
    {
        [self handleOptionSelectedAtIndexPath:indexPath];
    }
    else
    {
        [self showInspectionPointsForCraneAtIndexPath:indexPath];
    }
}

#pragma mark - Search Bar Delegate

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _tableDataCopy = [_tableData copy];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _tableData = _tableDataCopy;
    [self.tableView reloadData];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *searchedObjects = [NSMutableArray new];
    if (![searchText isEqualToString:@""])
    {
        for (InspectedCrane *crane in _tableDataCopy) {
            if (IS_OS_8_OR_LATER)
            {
                if ([[crane.hoistSrl lowercaseString] containsString:[searchText lowercaseString]])
                {
                    [searchedObjects addObject:crane];
                }
            }
            else {
                if ([[crane.hoistSrl lowercaseString] rangeOfString:searchText].location != NSNotFound) {
                    [searchedObjects addObject:crane];
                }
            }
        }
        
        _tableData = searchedObjects;
        [self.tableView reloadData];
    }
    else {
        _tableData = _tableDataCopy;
        [self.tableView reloadData];
    }
}

@end
