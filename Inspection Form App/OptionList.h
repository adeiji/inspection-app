//
//  Option.h
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionList : NSObject {
    NSMutableArray * theOptionList;
}

- (id) init;
- (NSMutableArray*) theOptionList;
- (void) setOption: (NSMutableArray*) input;
- (void) addOption: (NSString*) input;

@end
