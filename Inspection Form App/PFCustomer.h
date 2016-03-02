//
//  PFCustomer.h
//  Inspection Form App
//
//  Created by adeiji on 3/2/16.
//
//

#import <Parse/Parse.h>

@interface PFCustomer : PFObject <PFSubclassing>

+ (NSString *) parseClassName;

@property (retain) NSString *name;
@property (retain) NSString *contact;
@property (retain) NSString *address;
@property (retain) NSString *email;

@end
