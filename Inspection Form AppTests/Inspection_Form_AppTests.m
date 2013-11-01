//
//  Inspection_Form_AppTests.m
//  Inspection Form AppTests
//
//  Created by Developer on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Inspection_Form_AppTests.h"
#import <XCTest/XCTest.h>
#import "ViewController.h"

@implementation Inspection_Form_AppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testHoist
{
    ViewController *viewController = [[ViewController alloc] init];
    
    XCTAssertNil(nil, @"This failed");
}
@end
