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

@interface MasterViewController ()
{
    NSMutableArray *tableData;
    int level;
    NSDictionary *inspectionCriteria;
    NSString *valueToSearch;
    NSString *keyPathToSearch;
}
@end

@implementation MasterViewController

#define PART_NAME_COL @"partName"
#define TYPE_COL @"type"
#define COLLECTION_NAME @"test.inspectioncriterias"
#define PART_COL @"part"
#define OPTIONS_COL @"optionList"
#define OPTIONS_PATH @"type.part.partName"
#define PART_NAME_PATH @"type.typeName"
#define TYPE_NAME_COL @"typeName"


- (id)initWithStyle : (UITableViewStyle)style
              Level : (int) currentLevel
          NextValue : (NSString*) nextValue
       PathToSearch : (NSString*) keyToSearch

{
    self = [super initWithStyle:style];
    if (self) {
        level = currentLevel;
        valueToSearch = nextValue;
        keyPathToSearch = keyToSearch;
    }
    return self;
}

//Get the information that will be stored in the Table
- (void) getTableData : (NSString*) searchValue
{
    tableData = [[NSMutableArray alloc] init];
    
    NSArray *results = [MongoDbConnection getValues:searchValue keyPathToSearch:keyPathToSearch     collectionName:COLLECTION_NAME];
    
    
    if (level == PART_NAME)
    {
        for (int i = 0; i < results.count; i++) {
            NSDictionary *bsonDictionary = [results[i] dictionaryValue];
            NSArray *parts = [[bsonDictionary objectForKey:TYPE_COL] objectForKey:PART_COL];
            
            for (NSDictionary *value in parts)
            {
                //Pull the parts from the array that contains all the parts
                NSString *part = [value objectForKey:PART_NAME_COL];
                [tableData addObject:part];
            }
        }
    }
    else if (level == OPTIONS)
    {
        for (int i = 0; i < results.count; i++) {
            NSDictionary *bsonDictionary = [results[i] dictionaryValue];
            //Get all the parts from this specific document.
            NSArray *parts = [[bsonDictionary objectForKey:TYPE_COL] objectForKey:PART_COL];
            
            //Travers the parts to get the current part that we want
            for (int i = 0; i < [parts count]; i++) {
                //Once we've found the part that we're currently need.
                if ([[parts[i] objectForKey:PART_NAME_COL ]  isEqualToString:searchValue])
                {
                    //Get the options from the specific desired part.
                    NSArray *options = [parts[i] objectForKey:OPTIONS_COL];
                    
                    for (NSString *option in options) {
                        //Add the options to the array that will display in the table.
                        [tableData addObject:option];
                    }
                }
            }
        }
    }
    else
    {
        for (int i = 0; i < results.count; i++) {
            NSDictionary *bsonDictionary = [results[i] dictionaryValue];
            NSString *craneType = [[bsonDictionary objectForKey:TYPE_COL] objectForKey:TYPE_NAME_COL];
            [tableData addObject:craneType];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Get the data that will be stored in the table
    if (level != PART_NAME && level != OPTIONS)
    {
        valueToSearch = @"GET_ALL_VALUES";
        keyPathToSearch = nil;
    }
    
    [self getTableData : valueToSearch];
    
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, 50)];
    label.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, [tableData objectAtIndex:indexPath.row]];
    
    [cell addSubview:label];
    // Configure the cell...
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (level == PART_NAME)
    {
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:OPTIONS NextValue:[tableData objectAtIndex:indexPath.row] PathToSearch:OPTIONS_PATH];
        
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else if (level == OPTIONS)
    {
        
    }
    else
    {
        MasterViewController *mvc = [[MasterViewController alloc] initWithStyle:nil Level:PART_NAME NextValue:[tableData objectAtIndex:indexPath.row] PathToSearch:PART_NAME_PATH];
        
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
