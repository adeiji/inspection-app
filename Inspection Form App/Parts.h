//
//  Parts.h
//  Inspection Form App
//
//  Created by Developer on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parts : NSObject

@property (strong, nonatomic) NSMutableArray *myParts;

- (id) init;
- (void) fillParts;

@end
