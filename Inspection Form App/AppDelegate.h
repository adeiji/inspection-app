//
//  AppDelegate.h
//  Inspection Form App
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "SplitViewController.h"

@class SwitchViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SplitViewController *splitViewController;

@end
