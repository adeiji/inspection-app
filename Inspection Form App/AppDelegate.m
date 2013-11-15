//
//  AppDelegate.m
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Dropbox/Dropbox.h>
#import "MongoDbConnection.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#define SEARCH_VALUE @"GET_ALL_VALUES"
#define COLLECTION_NAME @"sswr.inspectioncriterias"
#define TYPE_COL @"type"
#define PART_COL @"part"
#define TYPE_NAME_COL @"typeName"
#define PART_NAME_COL @"partName"
#define OPTIONS_COL @"optionList"

@synthesize window = __window;
@synthesize searchCriteria = __searchCriteria;
@synthesize partsDictionary = __partsDictionary;
@synthesize optionsDictionary = __optionsDictionary;
@synthesize craneTypes = __craneTypes;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBAccountManager* accountMgr =[[DBAccountManager alloc] initWithAppKey:@"878n3v7pfduyrrr" secret:@"0745q3julqjk9mb"];
    [DBAccountManager setSharedManager:accountMgr];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        
        splitViewController.delegate = (id)navigationController.topViewController;                
    }
    
    [self getCriteriaFromMongoDb];
    [self fillCriteriaObjects];
    
    return YES;
}

- (void) getCriteriaFromMongoDb
{
    //Return everything from the mongo database
    __searchCriteria = [MongoDbConnection getValues:SEARCH_VALUE keyPathToSearch:nil collectionName:COLLECTION_NAME ];
}
//Fill the two dictionaries partsDictionary and searchDictionary so that we can easily pull these values from the array later
- (void) fillCriteriaObjects
{
    __optionsDictionary = [[NSMutableDictionary alloc] init];
    __partsDictionary = [[NSMutableDictionary alloc] init];
    __craneTypes = [[NSMutableArray alloc] init];
    for (int i = 0; i < __searchCriteria.count; i++)
    {
        NSDictionary *bsonDictionary = [__searchCriteria[i] dictionaryValue];
        
        //Get the type name that we're at in the array.
        NSString *typeName = [[bsonDictionary objectForKey:TYPE_COL] objectForKey:TYPE_NAME_COL];
        
        [__craneTypes addObject:typeName];
        
        NSArray *parts = [[bsonDictionary objectForKey:TYPE_COL] objectForKey:PART_COL];
        NSMutableArray *myParts = [[NSMutableArray alloc] init];
        
        for (NSDictionary *value in parts)
        {
            //Pull the parts from the array that contains all the parts
            NSString *part = [value objectForKey:PART_NAME_COL];
            NSArray *options = [value objectForKey:OPTIONS_COL];
            
            [__optionsDictionary setObject:options forKey:part];
            [myParts addObject:part];
        }
        
        [__partsDictionary setObject:myParts forKey:typeName];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
