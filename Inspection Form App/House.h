//
//  House.h
//  Inspection Form App
//
//  Created by Developer on 11/8/12.
//
//

#import <Foundation/Foundation.h>

@interface House : NSObject

@property NSString *type;
@property int numOfFloors;
@property NSString *typeofwindow;
@property NSString *typeoffloor;

-(id) init;
-(id) initWithParameters:(NSString*) myType: (int) myNumOfFloors: (NSString *) myTypeOfWindow:(NSString *) myTypeOfFloor;

@end
