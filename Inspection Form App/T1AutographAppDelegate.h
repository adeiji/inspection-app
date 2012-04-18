//
//  T1AutographAppDelegate.h
//  Inspection Form App
//
//  Created by Developer on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AutographViewController;

@interface T1AutographAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AutographViewController *viewController;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AutographViewController *viewController;

@end
