//
//  Crane.h
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import <Foundation/Foundation.h>

@interface Crane : NSObject

@property (strong, nonatomic) NSString* type;
@property (strong, nonatomic) NSString* capacity;
@property (strong, nonatomic) NSString* hoistMdl;
@property (strong, nonatomic) NSString* craneSrl;
@property (strong, nonatomic) NSString* hoistSrl;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* mfg;
@property (strong, nonatomic) NSString *hoistMfg;
@property (strong, nonatomic) NSString *equipmentNumber;

@end
