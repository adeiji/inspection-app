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

- (id)initWithStyle : (UITableViewStyle)style
              Level : (int) currentLevel
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
    
    if (!level) // If this is the crane list
    {
        _tableData = [[IACraneInspectionDetailsManager sharedManager] getAllInspectedCranes];
    }
    
}

- (void) setObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePart:) name:@"SwipeDetected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayParts:) name:kInspectionViewControllerPushed object:nil];
}

#pragma mark - Notification methods

- (void) displayParts : (NSNotification *) notification
{
    //Get the shared delegate so that we can get the parts dictionary.
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    //Reload the table data with the different part types.
    _tableData = [[NSMutableArray alloc] init];
    _tableData = [delegate.partsDictionary objectForKey: notification.userInfo[@"craneType"]];
    //Set the level to part name so that way when the user clicks on a part, we handle the click event as a part click event.
    level = PART_NAME;
    self.title = @"Parts";
    //Reload the data.
    [self.tableView reloadData];
}

- (void) changePart : (NSNotification *) notification
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if (level == OPTIONS)
    {
        //[self.navigationController popViewControllerAnimated:YES];
        _tableData = [[NSMutableArray alloc] init];
        _tableData = [delegate.optionsDictionary objectForKey: notification.userInfo[@"part"]];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
    id obj = [_tableData objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[InspectedCrane class]])
    {
        InspectedCrane *crane = (InspectedCrane *) obj;
        label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, crane.hoistSrl];
    }
    else {
        id obj = [_tableData objectAtIndex:indexPath.row];
        if ([obj respondsToSelector:@selector(name)]) {
            label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, [obj name]];
        }
    }
    
    [cell addSubview:label];
    // Configure the cell...
    
    return cell;
}

- (void) showInspectionPointsForCraneAtIndexPath : (NSIndexPath *) indexPath {
    InspectedCrane *crane = [_tableData objectAtIndex:indexPath.row];
    NSArray *inspectionCranes = [[IACraneInspectionDetailsManager sharedManager] getInspectionCraneOfType:crane.type];
    if ([inspectionCranes count] != 0)
    {
        InspectionCrane *inspectionCrane = inspectionCranes[0];
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:PART_NAME SearchValue:[inspectionCrane.inspectionPoints allObjects]];
        [self.navigationController pushViewController:mvc animated:YES];
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
    MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:OPTIONS SearchValue:[inspectionPoint.inspectionOptions allObjects]];
    
    //Get a reference to the current displayed view controller.
    UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
    ViewController *mainPageViewController = [navigationController.viewControllers objectAtIndex:0];
    //Push the InspectionViewController ontop of the stack.
    
    if (![mainPageViewController.navigationController.viewControllers containsObject:mainPageViewController.inspectionViewController])
    {
        [mainPageViewController storeInformationAndDisplayInspectionViewWithCrane:inspectionPoint.inspectionCrane SelectedRow:nil];
    }
    
    //Set the delegate to the InspectionViewController so that all changes are read by the inspection view controlller.
    __delegate = mainPageViewController.inspectionViewController;
    
    [self.navigationController pushViewController:mvc animated:YES];
    if (__delegate)
    {
        Part *part = [[Part alloc] init];
        [part setPart:[_tableData objectAtIndex:indexPath.row]];
        
        mainPageViewController.inspectionViewController.craneType = inspectionPoint.inspectionCrane.name;
        mainPageViewController.inspectionViewController.optionLocation = indexPath.row;
        [__delegate selectedPart:[_tableData objectAtIndex:indexPath.row]];
        
        mainPageViewController = nil;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (level == PART_NAME)
    {
        [self showOptionsForInspectionPointAtIndexPath:indexPath];
    }
    else if (level == OPTIONS)
    {
        [self handleOptionSelectedAtIndexPath:indexPath];
    }
    else
    {
        [self showInspectionPointsForCraneAtIndexPath:indexPath];
    }
}




@end
