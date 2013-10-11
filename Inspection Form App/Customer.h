//
//  Customer.h
//  Inspection Form App
//
//  Created by Developer on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#ifndef Inspection_Form_App_Customer_h
#define Inspection_Form_App_Customer_h


#endif

#import <UIKit/UIKit.h>

@interface Customer : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* contact;
@property (strong, nonatomic) NSString* address;
@property (strong, nonatomic) NSDate* date;
@property NSInteger *jobNumber;
@property (strong, nonatomic) NSString* equipDescription;
@property (strong, nonatomic) NSString* craneMfg;
@property (strong, nonatomic) NSString* hoistMfg;
@property (strong, nonatomic) NSString* hoistMdl;
@property (strong, nonatomic) NSString* hoistSrl;
@property (strong, nonatomic) NSString* equipmentNumber;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* description;


+ (Customer*) customer;

- (NSString *) name;
- (NSString *) contact;
- (NSString *) address;
- (NSDate *) date;
- (NSInteger *) jobNumber;
- (NSString *) equipDescription;
- (NSString *) craneMfg;
- (NSString *) hoistMfg;
- (NSString *) hoistMdl;

-(void) setName: (NSString*)input;
-(void) setContact: (NSString*)input;
-(void) setAddress: (NSString*)input;
-(void) setDate: (NSDate*)input;
-(void) setJobNumber: (NSInteger*)input;
-(void) setEquipDescription: (NSString*)input;
-(void) setCraneMfg: (NSString*)input;
-(void) setHoistMfg: (NSString*)input;
-(void) setHoistMdl: (NSString*)input;
@end