//
//  AppDelegate.h
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <Dropbox/Dropbox.h>

@class SwitchViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *searchCriteria;
@property (strong, nonatomic) NSMutableDictionary *partsDictionary;
@property (strong, nonatomic) NSMutableDictionary *optionsDictionary;
@property (strong, nonatomic) NSMutableArray *craneTypes;
@property (strong, nonatomic) NSArray *pastCranes;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void) saveContext;
- (NSURL *) applicationDocumentsDirectory;

@end
