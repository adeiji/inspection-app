//
//  PDFGenerator.h
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Inspection.h"

@interface PDFGenerator : NSObject <UIDocumentInteractionControllerDelegate>

//This text file that is written contains all the information that has been created: Customer Information; Crane Information; and Inspection Information
+ (void)  writeReport : (ItemListConditionStorage *) myConditionList
           Inspection : (Inspection*) inspection
        OverallRating : (NSString*) overallRating
           PartsArray : (NSArray*) myPartsArray;

+ (UIDocumentInteractionController *) DisplayPDFWithOverallRating : (Inspection *) inspection;
+ (void) createCertificate:(Inspection*) inspection;
+ (UIDocumentInteractionController *) displayCertificate : (Inspection*) inspection;
@end
