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
#import "MasterViewController.h"
#import "InspectionManager.h"
#import "InspectionBussiness.h"
#import <Parse/Parse.h>
#import "SyncManager.h"
#import "LoginViewController.h"
#import "Inspection_Form_App-Swift.h"

@import Bugsee;
@import FirebaseCore;

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
@synthesize pastCranes = __pastCranes;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setUpParseWithLaunchOptions:launchOptions];
    [Bugsee launchWithToken:@"a028b6a0-71dc-41a4-9eb3-d03b3c2a4d61"];
    
    [FIRApp configure];
    
    DBAccountManager* accountMgr =[[DBAccountManager alloc] initWithAppKey:@"878n3v7pfduyrrr" secret:@"0745q3julqjk9mb"];
    [DBAccountManager setSharedManager:accountMgr];
    [IACraneInspectionDetailsManager sharedManager];
    [[IACraneInspectionDetailsManager sharedManager] loadAllInspectionDetails];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setPersistentStoreCoordinator:(((AppDelegate *)[ [UIApplication sharedApplication] delegate]).managedObjectContext).persistentStoreCoordinator];
    
    IACraneInspectionDetailsManagerSwift *manager = [IACraneInspectionDetailsManagerSwift new];
    [manager backupCranesToFirebaseWithContext:context];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        if ([UtilityFunctions getUserId] != nil) {
            splitViewController.delegate = (id)navigationController.topViewController;
        }
        else {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
            [navigationController pushViewController:loginViewController animated:true];
        }
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPhone)
    {

    }

    [self fillCriteriaObjects];
    [self getPreviouslyFinishedCranes];
    
    return YES;
}

- (NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"InspectionModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Inspection Form App.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void) setUpParseWithLaunchOptions : (NSDictionary *) launchOptions {
    // Connect our app to Parse
    // Allow the parse local data store
//    [ParseCrashReporting enable];
    // Parse Keys - Livead
    
    
#ifdef DEBUG
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        [configuration setApplicationId:@"com.sswradmindev"];
        [configuration setClientKey:@"QiK7CN2M6Yh86Kn9FMLk8OBO0uHV9Icg0ryxrc11"];
        [configuration setServer:@"https://sswr-admin-dev.herokuapp.com/parse"];
    }]];
#else
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        [configuration setApplicationId:@"pXYoDYstnZ7wvICh2nNtxmAwegOpjhsdRpFjNoVE"];
        [configuration setClientKey:@"QiK7CN2M6Yh86Kn9FMLk8OBO0uHV9Icg0ryxrc11"];
        [configuration setServer:@"https://sswr-inspection-app.herokuapp.com/parse"];
    }]];
#endif
    
     
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

- (void) getPreviouslyFinishedCranes
{
    DBAccount * account = [[DBAccountManager sharedManager] linkedAccount];
    
    if (account)
    {
        DBDatastore *dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
        DBTable *table = [dataStore getTable:@"crane"];
    
        [dataStore sync:nil];
    
        __pastCranes = [InspectionBussiness getRecords:nil DBAccount:account DBDatastore:dataStore DBTable:table];
    }
}

//Fill the two dictionaries partsDictionary and searchDictionary so that we can easily pull these values from the array later
- (void) fillCriteriaObjects
{
    __optionsDictionary = [[NSMutableDictionary alloc] init];
    __partsDictionary = [[NSMutableDictionary alloc] init];
    __craneTypes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < __searchCriteria.count; i++)
    {
        NSDictionary *bsonDictionary;
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
        
        DBDatastore *dataStore = [DBDatastore openDefaultStoreForAccount:account error:nil];
        DBTable *table = [dataStore getTable:@"crane"];
        
        [dataStore sync:nil];
        
        __pastCranes = [InspectionBussiness getRecords:nil DBAccount:account DBDatastore:dataStore DBTable:table];
        
        return YES;
    }
    return NO;
}

- (void) saveContext {
    NSError *error;
    
    if ([_managedObjectContext save:&error] == NO) {
        NSLog(@"Error saving context %@", error.description);
    }
    
    
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
