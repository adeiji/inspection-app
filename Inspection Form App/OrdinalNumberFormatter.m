//
//  OrdinalNumberFormatter.m
//  Inspection Form App
//
//  Created by Developer on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OrdinalNumberFormatter.h"

@implementation OrdinalNumberFormatter

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error {
    NSInteger integerNumber;
    NSScanner *scanner;
    BOOL isSuccessful = NO;
    NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];

    scanner = [NSScanner scannerWithString:string];
    [scanner setCaseSensitive:NO];
    [scanner setCharactersToBeSkipped:letters];

    if ([scanner scanInteger:&integerNumber]){
        isSuccessful = YES;
    if (anObject) {
        *anObject = [NSNumber numberWithInteger:integerNumber];
    }
    } else {
        if (error) {
            *error = [NSString stringWithFormat:@"Unable to create number from %@", string];
        }
    }
    return isSuccessful;
}

- (NSString *)stringForObjectValue:(id)anObject {
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    NSString *strRep = [anObject stringValue];
    NSString *lastDigit = [strRep substringFromIndex:([strRep length]-1)];
    
    NSString *ordinal;
    
    
    if ([strRep isEqualToString:@"11"] || [strRep isEqualToString:@"12"] || [strRep isEqualToString:@"13"]) {
        ordinal = @"th";
    } else if ([lastDigit isEqualToString:@"1"]) {
        ordinal = @"st";
    } else if ([lastDigit isEqualToString:@"2"]) {
        ordinal = @"nd";
    } else if ([lastDigit isEqualToString:@"3"]) {
        ordinal = @"rd";
    } else {
        ordinal = @"th";
    }
    
    return [NSString stringWithFormat:@"%@%@", strRep, ordinal];
}


@end
