//
//  AutographViewController.h
//  Inspection Form App
//
//  Created by Developer on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <T1Autograph.h>

@interface AutographViewController : UIViewController <T1AutographDelegate> {
    T1Autograph *autograph;
    T1Autograph *autographModal;
    UIImageView *outputImage;
}

@property (retain) T1Autograph *autograph;
@property (retain) T1Autograph *secondAutograph;
@property (retain) T1Autograph *autographModal;
@property (retain) UIImageView *outputImage;

@end
