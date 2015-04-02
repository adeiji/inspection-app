//
//  Options.h
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef Inspection_Form_App_Options_h
#define Inspection_Form_App_Options_h

#endif

@interface Options : NSObject
    
@property (strong, nonatomic)  NSMutableArray* optionsArray;
    
- (id) initWithPart : (NSString*) part;
- (NSMutableArray*) myOptionsArray;
- (void) setMyOptionsArray: (NSMutableArray*) input;


@end