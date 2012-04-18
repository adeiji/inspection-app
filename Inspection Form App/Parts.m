//
//  Parts.m
//  Inspection Form App
//
//  Created by Developer on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Parts.h"

@implementation Parts
@synthesize myParts;

- (id) init {
    if (self = [super init])
    {
        myParts = [NSMutableArray array];
    }
    [self fillParts];
    return self;
}

- myParts {
    return myParts;
}

- (void)setMyParts:(NSMutableArray *)input {
    myParts = input;
}

- (void) fillParts {
    //Part 1
    [myParts addObject:@"Bridge Girder(s), Catwalk, Platform"];
    //Part 2
    [myParts addObject:@"Bridge End Trucks (Wield Bolts)"];
    //Part 3
    [myParts addObject:@"Bridge Wheel (Treads, Flanges, Axels)"];
    //Part 4
    [myParts addObject:@"Bridge Wheel Bearings"];
    //Part 5
    [myParts addObject:@"Bridge Wheel Gears, Pinions"];
    //Part 6
    [myParts addObject:@"Bridge Motor(Brushes Ect)"];
    //Part 7
    [myParts addObject:@"Bridge Motor Brake"];
    //Part 8
    [myParts addObject:@"Bridge Line Shaft, Couplings, Beaerings"];
    //Part 9
    [myParts addObject:@"Bridge Controls, Panel"];
    //Part 12
    [myParts addObject:@"Bridge Resistor/Soft Start"];
    //Part 13
    [myParts addObject:@"Trolley Frame"];
    //Part 14
    [myParts addObject:@"Trolley Wheels"];
    //Part 15
    [myParts addObject:@"Trolley Wheel Bearings, Gears and Pinions"];
    //Part 16
    [myParts addObject:@"Trolley Bumpers Drop Lugs and Stops"];
    //Part 17
    [myParts addObject:@"Trolley Motor"];
    //Part 18
    [myParts addObject:@"Trolley Motor Brake"];
    //Part 19
    [myParts addObject:@"Trolley Center Drive Shaft"];
    //Part 20
    [myParts addObject:@"Trolley Reducer"];
    //Part 21
    [myParts addObject:@"Trolley Panel/Controls"];
    //Part 22
    [myParts addObject:@"Trolley VFD/Soft/Start/Resistor"];
    //Part 23
    [myParts addObject:@"Load Hook"];
    //Part 24
    [myParts addObject:@"Hook Block, Sheaves, Bearings"];
    //Part 25
    [myParts addObject:@"Wire Rope, Load Chain, Fittings"];
    //Part 26
    [myParts addObject:@"Rope Drum, Anchors"];
    //Part 27
    [myParts addObject:@"Hoist Frame Suspension, Connection"];
    //Part 28
    [myParts addObject:@"Hoist Upper Tackle"];
    //Part 29
    [myParts addObject:@"Hoist Motor"];
    //Part 30
    [myParts addObject:@"Hoist Motor Brake"];
    //Part 31
    [myParts addObject:@"Hoist Load Brake"];
    //Part 32
    [myParts addObject:@"Hoist Limit Switches"];
    //Part 33
    [myParts addObject:@"Hoist Gear Train, Shafts, Coupling"];
    //Part 34
    [myParts addObject:@"Hoist Control Panel"];
    //Part 35
    [myParts addObject:@"Hoist Resistors, VFD, Soft Starts"];
    //Part 36
    [myParts addObject:@"Operator Instruction Card"];
    //Part 37
    [myParts addObject:@"Control Station Markings"];
    //Part 38
    [myParts addObject:@"Power Conductors/Collectors"];
    //Part 39
    [myParts addObject:@"Mainline Disconnect"];
    //Part 40
    [myParts addObject:@"Capacity Markings"];
    //Part 41
    [myParts addObject:@"Runway Beams"];
    //Part 42
    [myParts addObject:@"Runway Hardrail"];
    //Part 43
    [myParts addObject:@"Stairs, Railings"];
    //Part 44
    [myParts addObject:@"Operational Test, all functions"];
    //Part 45
    [myParts addObject:@"Operation Inspection of all Safety Gear"];
}
@end
