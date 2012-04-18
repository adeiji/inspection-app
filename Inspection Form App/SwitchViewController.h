//
//  SwitchViewController.h
//  Inspection Form App
//
//  Created by Developer on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchViewController : UIViewController
@property (strong, nonatomic) UIViewController *firstViewController;
@property (strong, nonatomic) UIViewController *secondViewController; 

- (IBAction)switchViews:(id)sender;

@end
