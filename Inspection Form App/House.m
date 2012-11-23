//
//  House.m
//  Inspection Form App
//
//  Created by Developer on 11/8/12.
//
//

#import "House.h"

@implementation House

@synthesize numOfFloors;
@synthesize type;
@synthesize typeoffloor;
@synthesize typeofwindow;

- (id) init
{
    
}

- (id) initWithParameters:(NSString *)myType :(int)myNumOfFloors :(NSString *)myTypeOfWindow :(NSString *)myTypeOfFloor
{
    type = myType;
    numOfFloors = myNumOfFloors;
    typeoffloor = myTypeOfFloor;
    typeofwindow = myTypeOfWindow;
}

@end
