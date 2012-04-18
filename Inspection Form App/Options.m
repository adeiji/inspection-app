//
//  Options.m
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Options.h"
#import "OptionList.h"

@implementation Options

- (id) init {
    if (self = [super init]) {
        myOptionsArray = [NSMutableArray array];
    }
    [self addMyOptions];
    return self;
}

- (NSMutableArray*) myOptionsArray {
    return myOptionsArray;
}
- (void) addMyOptions {
    OptionList* myOptionList = [[OptionList alloc] init];
    //Part 1
    [myOptionList addOption:@"Cracked Wields"];
    [myOptionList addOption:@"Bent/Ripped Handrail"];
    [myOptionList addOption:@"Conduit and Panel Fasteners Loose"];
    [myOptionList addOption:@"Hard Rail Attachment Loose/cracked"];
    [myOptionList addOption:@"Hardrail out of alignment"];
    [myOptionList addOption:@"Bent or Twisted Structure(evidence of overload or side load)"];
    [myOptionList addOption:@"Housekeeping on catwalks"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 2
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Fasteners to Girder Loose or Missing"];
    [myOptionList addOption:@"Rail Sweeps bent or missing"];
    [myOptionList addOption:@"Bumpers ripped/dried out or generally deteriorated"];
    [myOptionList addOption:@"Bridge motor attatchment"];
    [myOptionList addOption:@"Bridge gear reducer motor attatchment"];
    [myOptionList addOption:@"Ripped or torn seal on gear reducer"];
    [myOptionList addOption:@"End Truck Structure(stressed, overloaded, or heat damage)"];
    [myOptionList addOption:@"Bent drop lugs"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 3
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Worn Wheel Flange"];
    [myOptionList addOption:@"Worn Thread"];
    [myOptionList addOption:@"Axel Gearing Engagement(Gear Lash)"];
    [myOptionList addOption:@"Wheel Alignment"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 4
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Flat Bearing"];
    [myOptionList addOption:@"Missing Race"];
    [myOptionList addOption:@"Loss of interial ball or needle bearings"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];    
    //Part 5
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Gearing engagement(Gear Lash)"];
    [myOptionList addOption:@"Needs lubrication"];
    [myOptionList addOption:@"Worn teeth"];
    [myOptionList addOption:@"Cracked or deformed gears"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];   
    //Part 6
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Phase Loss(single phase)"];
    [myOptionList addOption:@"Worn brushes"];
    [myOptionList addOption:@"Worn Laminate"];
    [myOptionList addOption:@"Worn Insulation"];
    [myOptionList addOption:@"Missing Wire Connectors"];
    [myOptionList addOption:@"Deteriorated weather protection"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 7
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Disc's wear has regectable criteria"];
    [myOptionList addOption:@"Coil short"];
    [myOptionList addOption:@"Armature worn or out of alignment"];
    [myOptionList addOption:@"Mechanical connections missing or damaged"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];    
    //Part 8
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Shaft twisted or bent"];
    [myOptionList addOption:@"Couplings worn or bent"];
    [myOptionList addOption:@"Fasteners or welds on couplings are cracked, damaged or missing"];
    [myOptionList addOption:@"Pillow block bearings worn out"];
    [myOptionList addOption:@"Pillow block bearings need lube"];
    [myOptionList addOption:@"Line shaft gear engament in wheel is worn"];
    [myOptionList addOption:@"Line shaft gear engagement in wheel needs lube"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 9
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Loose attachment to structure"];
    [myOptionList addOption:@"Panels been bent and affects door operations"];
    [myOptionList addOption:@"Loose back plate"];
    [myOptionList addOption:@"Electrical components are loose"];
    [myOptionList addOption:@"Loose or exposed wires in the panel"];
    [myOptionList addOption:@"Contact tips are worn"];
    [myOptionList addOption:@"Mainline disconnect on bridge is in/op"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 12
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Resistors broken or cracked"];
    [myOptionList addOption:@"Resistor panel damaged"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Soft Start in/op"];
    [myOptionList addOption:@"Loose wires to resistors, VFD or soft start"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 13
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Structural dents, gouges, evidence of heat damage"];
    [myOptionList addOption:@"Cracked wields"];
    [myOptionList addOption:@"Missing or damaged fasteners"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 14
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Worn wheel flange"];
    [myOptionList addOption:@"Worn tread"];
    [myOptionList addOption:@"Axel gearing engagement(Gear Lash)"];
    [myOptionList addOption:@"Wheel alignment"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 15
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Flat bearing"];
    [myOptionList addOption:@"Missing race"];
    [myOptionList addOption:@"Loss of interior ball or needle bearings"];
    [myOptionList addOption:@"Gearing engagement(Gear Lash)"];
    [myOptionList addOption:@"Needs lubrication"];
    [myOptionList addOption:@"Worn teeth"];
    [myOptionList addOption:@"Cracked or deformed gears"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 16
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Bent sweeps"];
    [myOptionList addOption:@"Deteriorated/ripped bumpers"];
    [myOptionList addOption:@"Missing fasteners"];
    [myOptionList addOption:@"Bent drop lugs"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 17
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Phase loss(single phase)"];
    [myOptionList addOption:@"Worn brushes"];
    [myOptionList addOption:@"Worn laminate"];
    [myOptionList addOption:@"Worn insulation"];
    [myOptionList addOption:@"Missing wire connectors"];
    [myOptionList addOption:@"Deteriorated weather protection"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 18
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Disc's wear has rejectable criteria"];
    [myOptionList addOption:@"Coil short"];
    [myOptionList addOption:@"Armature worn or out of alignment"];
    [myOptionList addOption:@"Mechanical connections missing or damaged"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 19
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Shaft twisted or bent"];
    [myOptionList addOption:@"Couplings worn or bent"];
    [myOptionList addOption:@"Fasteners or wields on couplings are cracked, damaged or missing"];
    [myOptionList addOption:@"Pillow block bearings worn out"];
    [myOptionList addOption:@"Pillow block bearings need lube"];
    [myOptionList addOption:@"Line shaft gear engagement in wheel is worn"];
    [myOptionList addOption:@"Line shaft gear engagement in wheel needs lube"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 20
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Missing fasteners to motor or trolley end truck"];
    [myOptionList addOption:@"Worn gears(excessive gear lash)"];
    [myOptionList addOption:@"Needs lubrication"];
    [myOptionList addOption:@"Ripped or torn seal"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 21
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Loose attachment to structure"];
    [myOptionList addOption:@"Panels been bent and affects door operations"];
    [myOptionList addOption:@"Loose back plate"];
    [myOptionList addOption:@"Electrical components are loose"];
    [myOptionList addOption:@"Loose or exposed wires in the panel"];
    [myOptionList addOption:@"Contact tips are worn"];
    [myOptionList addOption:@"Mainline disconnect on bridge is in/op"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 22
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Resistors broken or cracked"];
    [myOptionList addOption:@"Resistor panel damaged"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Soft Start in/op"];
    [myOptionList addOption:@"Loose wires to resistors, VFD or soft start"];
    [myOptionList addOption:@"VFD in/op"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 23
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Over 10% wear in throat of hook"];
    [myOptionList addOption:@"Tip of hook stretched"];
    [myOptionList addOption:@"Excessive hook wear in the bail"];
    [myOptionList addOption:@"Latch is in/op"];
    [myOptionList addOption:@"Evidence of heat damage"];
    [myOptionList addOption:@"Gouges or dents"];
    [myOptionList addOption:@"Does not swivel freely"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 24
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Block reeved improperly"];
    [myOptionList addOption:@"Trunion worn causing hook slop"];
    [myOptionList addOption:@"Rope guard missing or damaged"];
    [myOptionList addOption:@"Cover bolts missing"];
    [myOptionList addOption:@"Pinion shaft worn"];
    [myOptionList addOption:@"Sheave flanges worn (bad fleet angle)"];
    [myOptionList addOption:@"Sheave tread worn (rope indentation)"];
    [myOptionList addOption:@"Sheave bearings froze or worn"];
    [myOptionList addOption:@"Blocks are missing cheek weight"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 25
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Wire rope abraded"];
    [myOptionList addOption:@"Wire rope corroded"];
    [myOptionList addOption:@"Wire rope exceeded the allowable broken wire count"];
    [myOptionList addOption:@"Wire rope kinked"];
    [myOptionList addOption:@"Evidence of heat damage to wire rope"];
    [myOptionList addOption:@"Wire rope needs to be lubed"];
    [myOptionList addOption:@"Chain nicked or gouged"];
    [myOptionList addOption:@"Chain needs lube"];
    [myOptionList addOption:@"Chain wear in saddle"];
    [myOptionList addOption:@"Chain is abraded"];
    [myOptionList addOption:@"Evidence of heat damage to link(s)"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 26
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Drum grooves are worn (sharp points at top of groove caused by poor fleet angles"];
    [myOptionList addOption:@"Drum attachment to trolley chassis is loose or damaged"];
    [myOptionList addOption:@"Drum anchors are missing or damaged"];
    [myOptionList addOption:@"Drum grooving profile does not match the rope"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 27
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Frame is twisted or bent"];
    [myOptionList addOption:@"Evidence of heat damage to hoist chassis"];
    [myOptionList addOption:@"Chassis has been welded"];
    [myOptionList addOption:@"Hoist chassis has cracked welds"];
    [myOptionList addOption:@"Missing suspension bolts"];
    [myOptionList addOption:@"Suspension bolts are loose"];
    [myOptionList addOption:@"Suspension bolt holes are worn"];
    [myOptionList addOption:@"Hoist/trolley connection is worn"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 28
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Sheave plate connection has cracked wields"];
    [myOptionList addOption:@"Sheave axel pin is worn"];
    [myOptionList addOption:@"Sheave axel pin is missing the keeper plate or bolts in keeper are loose or missing"];
    [myOptionList addOption:@"Sheave flanges worn (bad fleet angle)"];
    [myOptionList addOption:@"Sheave tread worn (rope indentation)"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 29
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Phase Loss (single phase)"];
    [myOptionList addOption:@"Worn brushes"];
    [myOptionList addOption:@"Worn laminate"];
    [myOptionList addOption:@"Worn insulation"];
    [myOptionList addOption:@"Missing wire connectors"];
    [myOptionList addOption:@"Deteriorated weather protection"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 30
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Disc's wear has rejectable criteria"];
    [myOptionList addOption:@"Coil short"];
    [myOptionList addOption:@"Armature worn or out of alignment"];
    [myOptionList addOption:@"Mechanical connections missing or damaged"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 31
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Load brake is locked up in both directions"];
    [myOptionList addOption:@"Will not support the load"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 32
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Geared limits in/op (upper, lower, or both)"];
    [myOptionList addOption:@"Weighted upper limit switch is in/op"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 33
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Describe"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 34
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Loose attachment to structure"];
    [myOptionList addOption:@"Panels been bent and affects door operations"];
    [myOptionList addOption:@"Loose back plate"];
    [myOptionList addOption:@"Electrical components are loose"];
    [myOptionList addOption:@"Loose or exposed wires in the panel"];
    [myOptionList addOption:@"Contact tips are worn"];
    [myOptionList addOption:@"Mainline disconnect on bridge is in/op"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 35
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Resistors broken or cracked"];
    [myOptionList addOption:@"Resistor panel damaged"];
    [myOptionList addOption:@"Loose conduit attaching to the panel"];
    [myOptionList addOption:@"Soft start in/op"];
    [myOptionList addOption:@"Loose wires to resistors, VFD or soft start"];
    [myOptionList addOption:@"VFD in/op"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 36
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Operator Instruction Card"];
    [myOptionList addOption:@"Missing"];
    [myOptionList addOption:@"Illegable"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 37
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Button covers missing or torn"];
    [myOptionList addOption:@"Housing is cracked"];
    [myOptionList addOption:@"Strain relieve of pendent is missing or damaged"];
    [myOptionList addOption:@"Function identification is illegible"];
    [myOptionList addOption:@"Functions are in/op"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 38
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Collector shoe brush contacts are worn"];
    [myOptionList addOption:@"Insulation on collector shoes leads are cracked or exposed"];
    [myOptionList addOption:@"Collector assy springs are weak"];
    [myOptionList addOption:@"Collector arm damaged"];
    [myOptionList addOption:@"Festoon Track is damaged"];
    [myOptionList addOption:@"Festoon trolleys damaged (tow trolley or intermediate)"];
    [myOptionList addOption:@"Festoon cable has exposed conductor(s)"];
    [myOptionList addOption:@"Cord grip fitting is damaged"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 39
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"No mainline disconnect at floor level"];
    [myOptionList addOption:@"No mainline disconnect at bridge level"];
    [myOptionList addOption:@"Mainline disconnect at floor level is obstructed"];
    [myOptionList addOption:@"Mailine disconnect is not labeled"];
    [myOptionList addOption:@"Conduit feed to mainline panel is damaged"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 40
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"No capacity labeled on the crane"];
    [myOptionList addOption:@"Capacity label is illegable"];
    [myOptionList addOption:@"Capacity ratings on the crane and hook block do not match"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 41
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Beams are out of alignment"];
    [myOptionList addOption:@"Splice plates damaged"];
    [myOptionList addOption:@"Splice plates are missing"];
    [myOptionList addOption:@"Fasteners in splice plates are missing or loose"];
    [myOptionList addOption:@"Fasteners in beams are missing or loose"];
    [myOptionList addOption:@"Wields connecting the runway beams to the support structure are cracked"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 42
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Handrail out of alignment"];
    [myOptionList addOption:@"Wields on rail clips are cracked"];
    [myOptionList addOption:@"J-bolts securing hardrail are loose"];
    [myOptionList addOption:@"Splice plates aon hardrail or loose or missing"];
    [myOptionList addOption:@"Hardrail is welded directly to the runway beam"];
    [myOptionList addOption:@"Other"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 43
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Housekeeping on stairs"];
    [myOptionList addOption:@"Slippery tread surface"];
    [myOptionList addOption:@"Handrail damaged"];
    [myOptionList addOption:@"Handrail connection to stairs damaged"];
    [myOptionList addOption:@"Missing or damaged engineered lanyard connection"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 44
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Notate"];
    [myOptionsArray addObject:myOptionList.theOptionList];
    //Part 45
    myOptionList = [[OptionList alloc] init];
    [myOptionList addOption:@"Notate"];
    [myOptionsArray addObject:myOptionList.theOptionList];
}
-(void) setMyOptionsArray:(NSMutableArray *)input {
    myOptionsArray = input;
}

@end
