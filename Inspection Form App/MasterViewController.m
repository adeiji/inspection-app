//
//  MasterViewController.m
//  Inspection Form App
//
//  Created by Ade on 10/16/13.
//
//

#import "MasterViewController.h"
#import "MongoDbConnection.h"
#import "BSONParser.h"
#import "OrderedDictionary.h"
#import "AppDelegate.h"

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

#define PART_NAME_COL @"partName"
#define TYPE_COL @"type"
#define COLLECTION_NAME @"sswr.inspectioncriterias"
#define PART_COL @"part"
#define OPTIONS_COL @"optionList"
#define OPTIONS_PATH @"type.part.partName"
#define PART_NAME_PATH @"type.typeName"
#define TYPE_NAME_COL @"typeName"


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
        tableData = delegate.craneTypes;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Get the mongo search criteria from the application delegate
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    results = delegate.searchCriteria;
    [self getTableData];
    
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
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:OPTIONS SearchValue:[tableData objectAtIndex:indexPath.row]];
        
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else if (level == OPTIONS)
    {
        
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
