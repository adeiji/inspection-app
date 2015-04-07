//
//  GradientView.m
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"
#import "QuartzCore/QuartzCore.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    self.clipsToBounds = NO;
    
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = .25;
}

@end
