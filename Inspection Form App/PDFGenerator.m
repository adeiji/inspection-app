//
//  PDFGenerator.m
//  Inspection Form App
//
//  Created by Ade on 10/11/13.
//
//

#import "PDFGenerator.h"
#import "OrdinalNumberFormatter.h"
#import "Inspection.h"

@implementation PDFGenerator

#define ANNUAL_OVERHEAD @"Annual Overhead Crane Inspection\n%@"
#define SSWR_HEADER_ADDRESS @"Silver State Wire Rope & Rigging\n8740 S. Jones Blvd Las Vegas, NV 89139\n(702) 597-2010 fax (702) 896-1977"
#define OWNER_NAME @"Owner\t\t %@"
#define OWNER_ADDRESS @"Owner's Address\t\t %@"
#define LOCATION @"Location\t\t %@"
#define DESCRIPTION @"Description\t\t %@ CRANE"
#define RATED_CAPACITY @"Rated Capacity\t\t %@"
#define CRANE_MANUFACTURER @"Crane Manufacturer"
#define SERIAL_NUMBER @"Serial No."
#define HOIST_MANUFACTURER @"Hoist Manufacturer"
#define MODEL @"Model"
#define OWNER_ID @"Owner's Identification (if any)\t%@"
#define TEST_LOADS_APPLIED @"Test loads applied (only if examination conducted)\t\t%@"
#define DESCRIPTION_OF_PROOF_LOAD @"Description of proof load:\t%@"
#define BASIS_FOR_ASSIGNED_LOAD_RATINGS @"Basis for assigned load ratings:\t%@"
#define REMARKS_LIMITATIONS_IMPOSED @"Remarks and/or limitations imposed:\t%@"
#define SLIP_WEIGHT @"Weight hoist slipped at:\t%@"
#define FOOTER @"I certify that on the %@th day of %@ %@ the above described device was tested X examined X by the undersigned; that said test and/or examination met with the requirements of the Division of Occupational Safety and Health Administration and ANSI B30 series orANSI/SIA A92.2 as applicable."
#define AUTHORIZED_CERTIFICATION_AGENT_ADDRESS @"Name and address of authorized certificating agent:"
#define SSWR_ADDRESS @"SILVER STATE WIRE ROPE AND RIGGING\n8740 S. JONES BLVD.\nLAS VEGAS, NV 89139"
#define EXPIRATION_DATE @"Expiration Date:\t%@"
#define TITLE @"Title: Crane Surveyor"
#define CERTIFICATE @"Certificate #SSWR - %@"
#define SIGNATURE @"Signature:"
#define NAME @"Name:\t%@"
#define DATE @"Date:\t%@"

- (void) drawTextToPDF : (NSString *) text
       RectangleToDraw : (CGRect *) rect
              FontSize : (CGFloat) fontSize

{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *dictionary = @{NSFontAttributeName : font};
    
    [text drawInRect:CGRectMake(95, 35, 270, 45) withAttributes:dictionary];
    
    
}

+ (void) drawContextToPDFContext : (CGContextRef) pdfContext
               StartPoint : (CGPoint) startPoint
                 EndPoint : (CGPoint) endPoint
{
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(pdfContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
}


+ (void) drawInContext : (CGContextRef) pdfContext {
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    UIImage *myImage = [UIImage imageNamed:@"logo.jpg"];
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    
    [myImage drawInRect:CGRectMake(-110, -30, 250, 250)];
    [myImage drawInRect:CGRectMake(50, 150, 500, 500) blendMode:kCGBlendModeLighten alpha:.15f];
    
    //Border lines
    //left vertical line
    [self drawContextToPDFContext:pdfContext StartPoint:CGPointMake(13, 231) EndPoint:CGPointMake(13, 780)];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 13, 231);
    CGContextAddLineToPoint(pdfContext, 13, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //right vertical lines
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 600, 13);
    CGContextAddLineToPoint(pdfContext, 600, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //top line
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 29, 13);
    CGContextAddLineToPoint(pdfContext, 600, 13);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //bottom line
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 13, 780);
    CGContextAddLineToPoint(pdfContext, 600, 780);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);

}

+ (void) MoveToPoint : (CGPoint) startPoint
       AndDrawString : (NSString *) string
              InRect : (CGRect) rect
         WithContext : (CGContextRef) pdfContext
          AddToPoint : (CGPoint) endPoint
            FontSize : (CGFloat) fontSize
     ParagraphyStyle : (NSParagraphStyle *) paragraphStyle
{
    NSDictionary *attributesDictionary = @{ NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                            NSParagraphStyleAttributeName : paragraphStyle } ;
    [string drawInRect:rect withAttributes:attributesDictionary];
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(pdfContext, endPoint.x, endPoint.y);
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);

}


+ (void) createCertificate:(Inspection*) inspection
{
    // Create URL for PDF file
    
    NSURL *fileURL = [NSURL fileURLWithPath:[self getFilePathForInspection:inspection]];
    CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)fileURL, NULL, NULL);
    [self drawInContext:pdfContext];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];

    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    [SSWR_HEADER_ADDRESS drawInRect:CGRectMake(95, 35, 270, 45) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f] }];
    [[NSString stringWithFormat:ANNUAL_OVERHEAD, inspection.inspectedCrane.type] drawInRect:CGRectMake(355, 35, 300, 50)withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f] }];
    
    [[NSString stringWithFormat:OWNER_NAME, inspection.customer.name] drawInRect:CGRectMake(50, 160, 500, 20) withAttributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                                                            NSParagraphStyleAttributeName : paragraphStyle
                                                                            }];
    CGContextSetLineWidth(pdfContext, 1);
    
    CGContextSetStrokeColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 110, 175);
    CGContextAddLineToPoint(pdfContext, 550, 175);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //  Owner Address
    [self MoveToPoint:CGPointMake(170, 205) AndDrawString:[NSString stringWithFormat:OWNER_ADDRESS, inspection.customer.address] InRect:CGRectMake(50, 190, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 205) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //  Location
    [self MoveToPoint:CGPointMake(120, 235) AndDrawString:[NSString stringWithFormat:LOCATION, inspection.inspectedCrane.hoistSrl] InRect:CGRectMake(50, 220, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 235) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Description
    [self MoveToPoint:CGPointMake(130, 265) AndDrawString:[NSString stringWithFormat:DESCRIPTION, inspection.inspectedCrane.craneDescription] InRect:CGRectMake(50, 250, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(260, 265) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Rated Capacity
    [self MoveToPoint:CGPointMake(355, 265) AndDrawString:[NSString stringWithFormat:RATED_CAPACITY, inspection.inspectedCrane.capacity] InRect:CGRectMake(255, 250, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 265) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Crane Manufacturer
    [self MoveToPoint:CGPointMake(180, 295) AndDrawString:CRANE_MANUFACTURER InRect:CGRectMake(50, 280, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(265, 295) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //Crane Mfg
    [inspection.inspectedCrane.mfg drawInRect:CGRectMake(180, 280, 230, 20) withAttributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
    
    //  Serial No
    [self MoveToPoint:CGPointMake(470, 295) AndDrawString:SERIAL_NUMBER InRect:CGRectMake(410, 280, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 295) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //  Crane Srl
    [inspection.inspectedCrane.craneSrl drawInRect:CGRectMake(470, 280, 230, 20) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:8.0f] }];
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    // Hoist Manufacturer
    [self MoveToPoint:CGPointMake(170, 325) AndDrawString:HOIST_MANUFACTURER InRect:CGRectMake(50, 310, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(265, 325) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //Hoist Mfg
    [inspection.inspectedCrane.hoistMfg drawInRect:CGRectMake(170, 310, 230, 20) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
    
    //LINE 7 Part 2
    [self MoveToPoint:CGPointMake(310, 325) AndDrawString:MODEL InRect:CGRectMake(270, 310, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(400, 325) FontSize:12.0f ParagraphyStyle:paragraphStyle];

    //Hoist Mdl
    [inspection.inspectedCrane.hoistMdl drawInRect:CGRectMake(310, 310, 230, 20) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:8.0f] }];
    
    // Serial Number Hoist
    [self MoveToPoint:CGPointMake(470, 325) AndDrawString:SERIAL_NUMBER InRect:CGRectMake(410, 310, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 325) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //Hoist Srl
    [self MoveToPoint:CGPointMake(470, 325) AndDrawString:inspection.inspectedCrane.hoistSrl InRect:CGRectMake(470, 310, 230, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 325) FontSize:8.0f ParagraphyStyle:paragraphStyle];
    
    // Owner Id
    [self MoveToPoint:CGPointMake(230, 355) AndDrawString:[NSString stringWithFormat:OWNER_ID, inspection.inspectedCrane.equipmentNumber] InRect:CGRectMake(50, 340, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 355) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Test Loads String
    [self MoveToPoint:CGPointMake(340, 385) AndDrawString:[NSString stringWithFormat:TEST_LOADS_APPLIED, inspection.testLoad] InRect:CGRectMake(50, 370, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 385) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Proof Load String
    [self MoveToPoint:CGPointMake(210, 415) AndDrawString:[NSString stringWithFormat:DESCRIPTION_OF_PROOF_LOAD, inspection.proofLoad] InRect:CGRectMake(50, 400, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 415) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    //  Load RatingsString
    [self MoveToPoint:CGPointMake(240, 445) AndDrawString:[NSString stringWithFormat:BASIS_FOR_ASSIGNED_LOAD_RATINGS, inspection.loadRatings] InRect:CGRectMake(50, 430, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 445) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    if (![inspection.inspectedCrane.type isEqualToString:ELECTRIC_HOIST])
    {
        //  Remarks Limitations String
        [self MoveToPoint:CGPointMake(270, 475) AndDrawString:[NSString stringWithFormat:REMARKS_LIMITATIONS_IMPOSED, inspection.remarksLimitations] InRect:CGRectMake(50, 460, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 475) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    }
    else {
        //  Remarks Limitations String
        [self MoveToPoint:CGPointMake(190, 475) AndDrawString:[NSString stringWithFormat:SLIP_WEIGHT, inspection.remarksLimitations] InRect:CGRectMake(50, 460, 500, 20) WithContext:pdfContext AddToPoint:CGPointMake(550, 475) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    }
    
    // Footer
    
    NSMutableParagraphStyle *footerParagraphStyle = [NSMutableParagraphStyle new];
    footerParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    footerParagraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *footerAttributesDictionary = @{ NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                                  NSParagraphStyleAttributeName : footerParagraphStyle };
    NSDateFormatter *dff = [[NSDateFormatter alloc] init];
    [dff setDateStyle:NSDateFormatterLongStyle];
    NSString *now = [dff stringFromDate:[NSDate date]];
    
    NSRange indexOfSpace = [now rangeOfString:@" "];
    NSString *month = [now substringToIndex:indexOfSpace.location];
    NSString *daySubstring = [now substringFromIndex:indexOfSpace.location + 1];
    NSRange indexOfComma = [daySubstring rangeOfString:@","];
    NSString *day = [daySubstring substringToIndex:indexOfComma.location];
    indexOfSpace = [daySubstring rangeOfString:@" "];
    NSString *year = [daySubstring substringFromIndex:indexOfSpace.location];
    
    NSString *footer = [NSString stringWithFormat:FOOTER, day, month, year];
    [footer drawInRect:CGRectMake(50, 495, 500, 120) withAttributes:footerAttributesDictionary];
    
    //LINE 15
    [AUTHORIZED_CERTIFICATION_AGENT_ADDRESS drawInRect:CGRectMake(50, 565, 500, 120) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
    
    //LINE 16
    [SSWR_ADDRESS drawInRect:CGRectMake(330, 565, 500, 120) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:11.0f] }];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 577);
    CGContextAddLineToPoint(pdfContext, 550, 577);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 590);
    CGContextAddLineToPoint(pdfContext, 445, 590);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 330, 605);
    CGContextAddLineToPoint(pdfContext, 450, 605);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24 * 365)];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterShortStyle];
    //  Expiration Date
    [self MoveToPoint:CGPointMake(140, 645) AndDrawString:[NSString stringWithFormat:EXPIRATION_DATE, [df stringFromDate:expirationDate]] InRect:CGRectMake(50, 630, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(300, 645) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Signature
    [self MoveToPoint:CGPointMake(390, 645) AndDrawString:SIGNATURE InRect:CGRectMake(330, 630, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(550, 645) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    SignatureManager *signatureManager = [SignatureManager new];
    UIImage *signatureImage = [signatureManager getSignature];
    [signatureImage drawInRect:CGRectMake(430, 595, 50, 60)];
    
    // Title
    [self MoveToPoint:CGPointMake(80, 685) AndDrawString:TITLE InRect:CGRectMake(50, 670, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(170, 685) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Inspector Name
    [self MoveToPoint:CGPointMake(370, 685) AndDrawString:[NSString stringWithFormat:NAME, inspection.technicianName] InRect:CGRectMake(330, 670, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(550, 685) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Certificate Number
    [self MoveToPoint:CGPointMake(165, 725) AndDrawString:[NSString stringWithFormat:CERTIFICATE, inspection.inspectedCrane.hoistSrl] InRect:CGRectMake(50, 710, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(300, 725) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Date
    [self MoveToPoint:CGPointMake(365, 725) AndDrawString:[NSString stringWithFormat:DATE, [df stringFromDate:[NSDate date]]] InRect:CGRectMake(330, 710, 500, 120) WithContext:pdfContext AddToPoint:CGPointMake(550, 725) FontSize:12.0f ParagraphyStyle:paragraphStyle];
    
    // Clean up
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);
    //release memory
    fileURL = nil;
    pdfContext = nil;
    
    [self displayCertificate:inspection];
}

+ (NSString *) createCustomerInfoTitleString {
    NSMutableString *printString = [NSMutableString stringWithString:@""];
    
    //customer information titles and descriptions
    [printString appendString:@"Customer Information\n\n"];
    [printString appendString:[NSMutableString stringWithFormat:@"Customer Name:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Customer Contact:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Job Number:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Email Address:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Customer Address:\n\n"]];
    
    return printString;
}

+ (NSString *) createCustomerInfoResultsStringWithInspection : (Inspection *) inspection {
    NSMutableString *customerInfoResultsColumn = [NSMutableString stringWithString:@""];
    
    //the customer information results
    
    [customerInfoResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", inspection.customer.name]];  //Customer - Name
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.customer.contact]];          //-Contact
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.jobNumber]];                 //-Job Number
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.customer.email]];            //-Email
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n\n", inspection.customer.address]];        //-Address
    
    return customerInfoResultsColumn;
}

+ (NSString *) createCraneDescriptionStringWithInspection : (Inspection *) inspection {

    NSMutableString *craneDescription = [NSMutableString stringWithString:@""];
    
    //Crane Description
    [craneDescription appendString:[NSString stringWithFormat:@"Crane Description: %@", inspection.inspectedCrane.craneDescription]];
    return craneDescription;
}

+ (NSString *) createCraneDescriptionLeftColumnString {
    NSMutableString *craneDescriptionLeftColumn = [NSMutableString stringWithString:@""];
    
    //the crane description titles
    [craneDescriptionLeftColumn appendString:@"Overall Condition Rating:\n"];
    [craneDescriptionLeftColumn appendString:@"Crane Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Model:\n"];
    
    return craneDescriptionLeftColumn;
}

+ (NSString *) createCraneDescriptionResultsColumnWithInspection : (Inspection *) inspection
                                                   OverallRating : (NSString *) overallRating  {
    NSMutableString *craneDescriptionResultsColumn = [NSMutableString stringWithString:@""];
    
    //crane description results
    [craneDescriptionResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", overallRating]];
    //CraneMfg
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.mfg]];
    //HoistMfg

    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.hoistMfg]];
    //HoistMdl
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.hoistMdl]];
    
    return craneDescriptionResultsColumn;
}

+ (NSString *) createCraneDescriptionRightColumnWithInspection {
    NSMutableString *craneDescriptionRightColumn = [NSMutableString stringWithString:@""];
    
    //crane description titles right column
    [craneDescriptionRightColumn appendString:@"\n\nCap:\n"];
    [craneDescriptionRightColumn appendString:@"Crane Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Hoist Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Equip #:\n"];
    
    return craneDescriptionRightColumn;
}

+ (NSString *) createCraneDescriptionRightResultsColumnWithInspection : (Inspection *) inspection {
    NSMutableString *craneDescriptionRightResultsColumn = [NSMutableString stringWithString:@""];
    
    //creane description results
    
    [craneDescriptionRightResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", inspection.inspectedCrane.capacity]];      //-Crane-Capacity
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.craneSrl]];  // Crane Srl
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.hoistSrl]];   // Hoist Srl
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.inspectedCrane.equipmentNumber]];  //Equipment Number
    
    return craneDescriptionRightResultsColumn;
}

/*
 
 Go through every single part that is associated with this crane and write it's details to string
 
 */
+ (void) updateCraneInspectionDetailsStringsWithConditionList : (ItemListConditionStorage *) myConditionList
                                         PartDeficiencyString : (NSMutableString **) partDeficiency
                                                    PartNotes : (NSMutableString **) partNotes
                                                    PartTitle : (NSMutableString **) partTitle
                                                   PartsArray : (NSArray *) myPartsArray
{
    int optionNumber = 0;
    for (Condition *myCondition in myConditionList.myConditions)
    {
        if (myCondition.applicable == NO)
        {
            if (myCondition.deficient == YES){
                [*partDeficiency appendString:@"Failed\n"];
                [*partNotes appendString:[NSString stringWithFormat:@"%d.  %@: %@\n",optionNumber + 1, myCondition.deficientPart, myCondition.notes]];
            }
            else if (myCondition.deficient==NO) {
                if (![myCondition.notes isEqualToString:@""])
                {
                    [*partNotes appendString:[NSString stringWithFormat:@"%d.  %@\n",optionNumber + 1, myCondition.notes]];
                }
                [*partDeficiency appendString:@"Passed\n"];
            }
        }
        else {
            [*partDeficiency appendString:@"N/A\n"];
        }
        InspectionPoint *inspectionPoint = [myPartsArray objectAtIndex:optionNumber];
        [*partTitle appendString:[NSString stringWithFormat:@"%d. %@\n",optionNumber + 1, inspectionPoint.name ]];
        optionNumber ++;
    }
    
}


//This text file that is written contains all the information that has been created: Customer Information; Crane Information; and Inspection Information
+ (void)  writeReport : (ItemListConditionStorage *) myConditionList
           Inspection : (Inspection*) inspection
        OverallRating : (NSString*) overallRating
           PartsArray : (NSArray*) myPartsArray
{

    NSMutableString *partTitle = [NSMutableString stringWithString:@""];
    NSMutableString *partDeficiency = [NSMutableString stringWithString:@""];
    NSMutableString *partNotes = [NSMutableString stringWithString:@""];
    NSMutableString *deficientPartString = [NSMutableString stringWithString:@""];
    NSMutableString *footerLeft = [NSMutableString stringWithString:@""];
    NSMutableString *footerRight = [NSMutableString stringWithString:@""];
    NSMutableString *header = [NSMutableString stringWithString:@""];

    NSString *customerInfoTitleString = [self createCustomerInfoTitleString];
    NSString *customerInfoResultsColumn = [self createCustomerInfoResultsStringWithInspection:inspection];
    NSString *craneDescriptionLeftColumn = [self createCraneDescriptionLeftColumnString];
    NSString *craneDescriptionResultsColumn = [self createCraneDescriptionResultsColumnWithInspection:inspection OverallRating:overallRating];
    NSString *craneDescriptionRightColumn = [self createCraneDescriptionRightColumnWithInspection];
    NSString *craneDescriptionRightResultsColumn = [self createCraneDescriptionRightResultsColumnWithInspection:inspection];
    NSString *craneDescription = [self createCraneDescriptionStringWithInspection:inspection];
    [self updateCraneInspectionDetailsStringsWithConditionList:myConditionList
                                          PartDeficiencyString:&partDeficiency
                                                     PartNotes:&partNotes
                                                     PartTitle:&partTitle
                                                    PartsArray:myPartsArray];
    [footerLeft appendString:[NSString stringWithFormat:@"Technician:%@\nDate: %@",inspection.technicianName, inspection.date]];    //Technician Name
    [footerRight appendString:[NSString stringWithFormat:@"Customer:%@\nDate: %@",inspection.customer.name, inspection.date]];      //Customer name and date
    [header appendString:[NSString stringWithFormat:@"Silverstate Wire Rope and Rigging\n\n24-Hour Emergency Service\nSales - Service - Repair\nElectrical - Mechanical - Pneumatic\nCal-OSHA Accredited"]];
    
    
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF",inspection.customer.name, inspection.inspectedCrane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    NSString *filePath = pdfFileName;
    
    
    [self CreatePDFFile:customerInfoTitleString
                       :customerInfoResultsColumn
                       :craneDescriptionLeftColumn
                       :craneDescriptionResultsColumn
                       :craneDescriptionRightColumn
                       :craneDescriptionRightResultsColumn
                       :filePath
                       :partDeficiency
                       :partTitle
                       :partNotes
                       :deficientPartString
                       :footerLeft
                       :footerRight
                       :header
                       :craneDescription];

}

+ (void) CreatePDFFile:(NSString *) printString
                      :(NSString *) customerInfoResultsColumn
                      :(NSString *) craneDescriptionLeftColumn
                      :(NSString *) craneDescriptionResultsColumn
                      :(NSString *) craneDescriptionRightColumn
                      :(NSString *) craneDescriptionRightResultsColumn
                      :(NSString *) filePath
                      :(NSString *) partDeficiency
                      :(NSString *) partTitle
                      :(NSString *) partNotes
                      :(NSString *) deficientPartString
                      :(NSString *) footerLeft
                      :(NSString *) footerRight
                      :(NSString *) header
                      :(NSString *) craneDescription
{
    // Create URL for PDF file
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)fileURL, NULL, NULL);
    CGPDFContextBeginPage(pdfContext, NULL);
    UIGraphicsPushContext(pdfContext);
    UIImage *myImage = [UIImage imageNamed:@"logo.jpg"];
    // Flip coordinate system
    CGRect bounds = CGContextGetClipBoundingBox(pdfContext);
    CGContextScaleCTM(pdfContext, 1.0, -1.0);
    CGContextTranslateCTM(pdfContext, 0.0, -bounds.size.height);
    NSString *conditionRatingString = @"Crane Condition Rating: \n1=Great \n2=Good Minor Problems (scheduled repair) \n3=Maintenance Problems(Immediate Repair) \n4=Safety Concern(Immediate Repair) \n5=Crane's conditions require it to be taged out";
    
    // Drawing commands
    //[printString drawAtPoint:CGPointMake(100, 100) withFont:[UIFont boldSystemFontOfSize:12.0f]];
    [myImage drawInRect:CGRectMake(50, 150, 500, 500) blendMode:kCGBlendModeLighten alpha:.15f];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment =  NSTextAlignmentLeft;
    
    [header drawInRect:CGRectMake(20, 20, 200, 200) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f], NSParagraphStyleAttributeName : paragraphStyle }];
//    [header drawInRect:CGRectMake(20, 20, 200, 200) withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    [printString drawInRect:CGRectMake(225, 20, 120 , 120)  withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f], NSParagraphStyleAttributeName : paragraphStyle }];
//                   withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    [customerInfoResultsColumn drawInRect:CGRectMake(325, 20, 400, 120) withAttributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
//    [customerInfoResultsColumn drawInRect:CGRectMake(325, 20, 400, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescription drawInRect:CGRectMake(20, 120, 500, 160) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
//    [craneDescription drawInRect:CGRectMake(20, 120, 500, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionLeftColumn drawInRect:CGRectMake(20, 145, 120, 160) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f] }];
//    [craneDescriptionLeftColumn drawInRect:CGRectMake(20, 145, 120, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionResultsColumn drawInRect:CGRectMake(140, 120, 150, 120) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]}];
//    [craneDescriptionResultsColumn drawInRect:CGRectMake(140, 120, 150, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightColumn drawInRect:CGRectMake(300, 120, 120, 120) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]}];
//    [craneDescriptionRightColumn drawInRect:CGRectMake(300, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightResultsColumn drawInRect:CGRectMake(410, 120, 120, 120) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]}];
//    [craneDescriptionRightResultsColumn drawInRect:CGRectMake(410, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [partTitle drawInRect:CGRectMake(20, 220, 300, 700) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [partTitle drawInRect:CGRectMake(20, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partDeficiency drawInRect:CGRectMake(235, 220, 120, 700) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [partDeficiency drawInRect:CGRectMake(235, 220, 120, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partNotes drawInRect:CGRectMake(310, 220, 220, 700) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [partNotes drawInRect:CGRectMake(310, 220, 220, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [deficientPartString drawInRect:CGRectMake(500, 220, 300, 700) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [deficientPartString drawInRect:CGRectMake(500, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [conditionRatingString drawInRect:CGRectMake(20, 700, 600, 70) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [conditionRatingString drawInRect:CGRectMake(20, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerLeft drawInRect:CGRectMake(300, 700, 600, 70) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8.0f]}];
//    [footerLeft drawInRect:CGRectMake(300, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerRight drawInRect:CGRectMake(450, 700, 600, 70) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]}];
//    [footerRight drawInRect:CGRectMake(450, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    
    SignatureManager *manager = [SignatureManager new];
    UIImage *image = [manager getSignature];
    [image drawInRect:CGRectMake(300, 400, 300, 175)];
    
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);
//    [self displayComposerSheet];
    //release memory
    fileURL = nil;
    pdfContext = nil;
    myImage = nil;
    conditionRatingString = nil;
}

+ (NSString *) getFilePathForInspection : (Inspection *) inspection {
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF", inspection.customer.name, inspection.inspectedCrane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    return pdfFileName;

}

+ (UIDocumentInteractionController *) DisplayPDFWithOverallRating : (Inspection *) inspection
{
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF", inspection.customer.name, inspection.inspectedCrane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    UIDocumentInteractionController *pdfViewController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pdfFileName]];
    
    return pdfViewController;
    
    //[self writeCertificateTextFile];
}

+ (UIDocumentInteractionController *) displayCertificate : (Inspection*) inspection  {
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF", inspection.customer.name, inspection.inspectedCrane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    UIDocumentInteractionController *pdfViewController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pdfFileName]];
    
    [pdfViewController presentPreviewAnimated:NO];
    

    return pdfViewController;
}

@end
