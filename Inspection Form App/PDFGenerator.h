//
//  PDFGenerator.h
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Inspection.h"

@interface PDFGenerator : NSObject

+ (void) writeCertificateTextFile : (NSString*) testLoads
             ProofLoadDescription : (NSString*) proofLoadDescription
         RemarksLimitationImposed : (NSString*) remarksLimitationsImposed
                  LoadRatingsText : (NSString*) loadRatingsText
                       Inspection : (Inspection *) inspection;

+ (void) DisplayPDFWithOverallRating : (Inspection *) inspection;
@end
