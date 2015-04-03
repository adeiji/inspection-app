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
{
    NSMutableArray *tableData;
    int level;
    NSDictionary *inspectionCriteria;
    NSArray *results;
    NSString *searchValue;
}
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
        SearchValue : (NSString*) mySearchValue

{
    self = [super initWithStyle:style];
    if (self) {
        level = currentLevel;
        searchValue = mySearchValue;
    }
    
    return self;
}

//Get the information that will be stored in the Table
- (void) getTableData
{
    tableData = [[NSMutableArray alloc] init];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    //If we're retrieving only the partNames
    if (level == PART_NAME)
    {
        
        [delegate.partsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id part, BOOL *stop) {
            if ([key isEqualToString:searchValue])
            {
                for (int i = 0; i < [part count]; i ++)
                {
                    [tableData addObject:part[i]];
                }
            }
        } ];
        
    }
    else if (level == OPTIONS)
    {
        [delegate.optionsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id options, BOOL *stop) {
            if ([key isEqualToString:searchValue])
            {
                for (int i = 0; i < [options count]; i++) {
                    [tableData addObject:options[i]];
                }
            }
        }];
    }
    else
        
    {
        for (DBRecord *result in delegate.pastCranes)
        {
            //Get all the cranes that were done previously
            [tableData addObject:result[COLUMN_CONTAINING_TOP_ELEMENTS]];
        }
    }
    
    delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setObservers];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    results = delegate.searchCriteria;
    [self getTableData];
    
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
    tableData = [[NSMutableArray alloc] init];
    tableData = [delegate.partsDictionary objectForKey: notification.userInfo[@"craneType"]];
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
        tableData = [[NSMutableArray alloc] init];
        tableData = [delegate.optionsDictionary objectForKey: notification.userInfo[@"part"]];
        
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
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
    label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, [tableData objectAtIndex:indexPath.row]];
    
    [cell addSubview:label];
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (level == PART_NAME)
    {
        //Create the Master View controller that we will push onto the view controller stack.
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:OPTIONS SearchValue:[tableData objectAtIndex:indexPath.row]];
        //Get a reference to the current displayed view controller.
        
        UINavigationController *navigationController = [self.splitViewController.viewControllers objectAtIndex:1] ;
        ViewController *vc = [navigationController.viewControllers objectAtIndex:0];
        //Push the InspectionViewController ontop of the stack.
        
        if (![vc.navigationController.viewControllers containsObject:vc.inspectionViewController])
        {
            [vc.navigationController pushViewController:vc.inspectionViewController animated:YES];
        }
        //Set the delegate to the InspectionViewController so that all changes are read by the inspection view controlller.
        __delegate = vc.inspectionViewController;
        [self.navigationController pushViewController:mvc animated:YES];
        if (__delegate)
        {
            Part *part = [[Part alloc] init];
            [part setPart:[tableData objectAtIndex:indexPath.row]];
            
            vc.inspectionViewController.craneType = searchValue;
            vc.inspectionViewController.optionLocation = indexPath.row;
            [__delegate selectedPart:[tableData objectAtIndex:indexPath.row]];
            
            vc = nil;
        }
    }
    else if (level == OPTIONS)
    {
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
            [__delegate selectedOption:[tableData objectAtIndex:indexPath.row]];
        }
    }
    else
    {
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:PART_NAME SearchValue:[tableData objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:mvc animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
