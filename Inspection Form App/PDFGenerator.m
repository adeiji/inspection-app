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

+ (void) writeCertificateTextFile : (NSString*) testLoads
             ProofLoadDescription : (NSString*) proofLoadDescription
         RemarksLimitationImposed : (NSString*) remarksLimitationsImposed
                  LoadRatingsText : (NSString*) loadRatingsText
                       Inspection : (Inspection *) inspection
{
    if (![testLoads isEqual:NULL])
    {
        NSMutableString *headerString = [NSMutableString stringWithString:@""];
        NSMutableString *ownerString = [NSMutableString stringWithString:@""];
        NSMutableString *ownerAddressString = [NSMutableString stringWithString:@""];
        NSMutableString *device = [NSMutableString stringWithString:@""];
        NSMutableString *location = [NSMutableString stringWithString:@""];
        NSMutableString *description = [NSMutableString stringWithString:@""];
        NSMutableString *ratedCapacity = [NSMutableString stringWithString:@""];
        NSMutableString *craneManafacturer = [NSMutableString stringWithString:@""];
        NSMutableString *modelCrane = [NSMutableString stringWithString:@""];
        NSMutableString *serialNoCrane = [NSMutableString stringWithString:@""];
        NSMutableString *hoistManufacturer = [NSMutableString stringWithString:@""];
        NSMutableString *modelHoist = [NSMutableString stringWithString:@""];
        NSMutableString *serialNoHoist = [NSMutableString stringWithString:@""];
        NSMutableString *ownerID = [NSMutableString stringWithString:@""];
        NSMutableString *lifting = [NSMutableString stringWithString:@""];
        NSMutableString *other = [NSMutableString stringWithString:@""];
        NSMutableString *testLoadsString = [NSMutableString stringWithString:@""];
        NSMutableString *proofLoadString = [NSMutableString stringWithString:@""];
        NSMutableString *loadRatingsString = [NSMutableString stringWithString:@""];
        NSMutableString *remarksLimitationsString = [NSMutableString stringWithString:@""];
        NSMutableString *footer = [NSMutableString stringWithString:@""];
        NSMutableString *nameAddress = [NSMutableString stringWithString:@""];
        NSMutableString *expirationDate = [NSMutableString stringWithString:@""];
        NSMutableString *signature = [NSMutableString stringWithString:@""];
        NSMutableString *title = [NSMutableString stringWithString:@""];
        NSMutableString *inspectorName = [NSMutableString stringWithString:@""];
        NSMutableString *certificateNum = [NSMutableString stringWithString:@""];
        NSMutableString *date = [NSMutableString stringWithString:@""];
        NSMutableString *address = [NSMutableString stringWithString:@""];
        NSMutableString *headerTitle = [NSMutableString stringWithString:@""];
        NSMutableString *titleAddress = [NSMutableString stringWithString:@""];
        
        [headerString appendString:@"ANNUAL OVERHEAD BRIDGE INSPECTION: \n"];
        [headerString appendString:[NSString stringWithFormat:@"%@", @"BRIDGE, MONORAIL, JIB"]];
        
        if ([inspection.customer.name isEqualToString:@"LVVWD"])
        {
            [ownerString appendString:[NSString stringWithFormat:@"1.  Owner      %@", @"Las Vegas Valley Water District"]];
        }
        else {
            [ownerString appendString:[NSString stringWithFormat:@"1.  Owner     %@", inspection.customer.name]];
        }
        
        [titleAddress appendString:[NSString stringWithFormat:@"Silver State Wire Rope & Rigging\n8740 S. Jones Blvd Las Vegas, NV 89139\n(702) 597-2010 fax (702)896-1977"]];
        [headerTitle appendString:[NSString stringWithFormat:@"Annual Overhead Crane Inspection:\n%@", inspection.crane.description]];
        [ownerAddressString appendString:[NSString stringWithFormat:@"2.  Owner's Address      %@", inspection.customer.address]];
        [location appendString:[NSString stringWithFormat:@"3.  Location      %@", inspection.customer.equipmentNumber]];
        [description appendString:[NSString stringWithFormat:@"4.  Description    %@ CRANE", inspection.crane.description]];
        [ratedCapacity appendString:[NSString stringWithFormat:@"    Rated Capacity      %@", inspection.crane.capacity]];
        [craneManafacturer appendString:[NSString stringWithFormat:@"5.  Crane Manufacturer"]];
        [modelCrane appendString:[NSString stringWithFormat:@"Model"]];
        [serialNoCrane appendString:[NSString stringWithFormat:@"Serial No."]];
        [hoistManufacturer appendString:[NSString stringWithFormat:@"6.  Hoist Manafacture"]];
        [modelHoist appendString:[NSString stringWithFormat:@"Model"]];
        [serialNoHoist appendString:[NSString stringWithFormat:@"Serial No."]];
        [ownerID appendString:[NSString stringWithFormat:@"7.  Owner's Identification (if any)      %@", inspection.crane.equipmentNumber]];
        [testLoadsString appendString:[NSString stringWithFormat:@"8. Test loads applied (only if examination conducted):   %@", testLoads]];
        [proofLoadString appendString:[NSString stringWithFormat:@"9. Description of proof load:   %@", proofLoadDescription]];
        [loadRatingsString appendString:[NSString stringWithFormat:@"10. Basis for assigned load ratings:   %@", loadRatingsText]];
        [remarksLimitationsString appendString:[NSString stringWithFormat:@"11. Remarks and/or limitations imposed:   %@", remarksLimitationsImposed]];
        //convert the date of the inspection to the Long Date format
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:inspection.date];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateFromString];
        
        NSInteger day = [components day];
        //convert day to an NSNumber so that it can be sent to OrdinalNumberFormatter which will turn the NSNumber into an ORdinal Number
        NSNumber *myNumDay = [NSNumber numberWithInt:day];
        NSInteger month = [components month];
        NSInteger year = [components year];
        NSString *monthName = [[dateFormatter monthSymbols] objectAtIndex:(month - 1)];
        OrdinalNumberFormatter *formatter = [[OrdinalNumberFormatter alloc] init];
        
        NSString *myDay = [formatter stringForObjectValue:myNumDay];
        
        [footer appendString:[NSString stringWithFormat:@"I certify that on the %@ day of %@ %d the above described device was tested and \n examined by the undersigned; that said test and/or examination met with the requirements \n of the Division of Occupational Safety and Health Administration and ANSI B30 series or \nANSI/SIA A92.2 as applicable. ", myDay, monthName, year]];
        [nameAddress appendString:[NSString stringWithFormat:@"Name and address of authorized certificating agent: "]];
        [address appendString:[NSString stringWithFormat:@"SILVER STATE WIRE ROPE AND RIGGING\n8740 S. JONES BLVD.\nLAS VEGAS, NV 89139"]];
        [expirationDate appendString:[NSString stringWithFormat:@"Expiration Date:  %d/%d/%d", month, day, year + 1]];
        [signature appendString:[NSString stringWithFormat:@"Signature: "]];
        [title appendString:[NSString stringWithFormat:@"Title: Crane Surveyor"]];
        [inspectorName appendString:[NSString stringWithFormat:@"Name: %@", inspection.technicianName]];
        [certificateNum appendString:[NSString stringWithFormat:@"Certificate #LVVWD- %@", inspection.crane.equipmentNumber]];
        [date appendString:[NSString stringWithFormat:@"Date:   %@", inspection.date]];
        
        //Create the file
        
        //Initiate Error Catching
        //NSError *error;
        
        //create file manager
        
        NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF",inspection.customer.name, inspection.crane.hoistSrl, dateNoSlashes];
        
        NSArray *arrayPaths =
        NSSearchPathForDirectoriesInDomains(
                                            NSDocumentDirectory,
                                            NSUserDomainMask,
                                            YES);
        NSString *path = [arrayPaths objectAtIndex:0];
        NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
        
        //NSString *documentsDirectory = @"/Users/Developer/Documents";
        NSString *filePath = pdfFileName;
        //NSString *afilePath = [documentsDirectory stringByAppendingPathComponent:@"jobInfoArray.txt"];
        
        // NSLog(@"string to write:%@", printString);
        
        //[printString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        [self createCertificate:titleAddress
                               :headerTitle
                               :headerString
                               :ownerString
                               :ownerAddressString
                               :device
                               :location
                               :description
                               :ratedCapacity
                               :craneManafacturer
                               :modelCrane
                               :serialNoCrane
                               :hoistManufacturer
                               :modelHoist
                               :serialNoHoist
                               :ownerID
                               :lifting
                               :other
                               :testLoadsString
                               :proofLoadString
                               :loadRatingsString
                               :remarksLimitationsString
                               :footer
                               :nameAddress
                               :address
                               :expirationDate
                               :signature
                               :title
                               :inspectorName
                               :certificateNum
                               :date
                               :filePath
                               :inspection];
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must first fill out an application" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) drawTextToPDF : (NSString *) text
       RectangleToDraw : (CGRect *) rect
              FontSize : (CGFloat) fontSize

{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *dictionary = @{NSFontAttributeName : font};
    
    [text drawInRect:CGRectMake(95, 35, 270, 45) withAttributes:dictionary];
    
    
}

- (void) drawContextToPDF :
               PDFContext : (CGContextRef) pdfContext
               StartPoint : (CGPoint) startPoint
                 EndPoint : (CGPoint) endPoint
{
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(pdfContext, endPoint.x, endPoint.y);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
}

+ (void) createCertificate:(NSString *) titleAddress
                          :(NSString *) headerTitle
                          :(NSString *) headerString
                          :(NSString *) ownerString
                          :(NSString *) ownerAddressString
                          :(NSString *) device
                          :(NSString *) location
                          :(NSString *) description
                          :(NSString *) ratedCapacity
                          :(NSString *) craneManafacturer
                          :(NSString *) modelCrane
                          :(NSString *) serialNoCrane
                          :(NSString *) hoistManufacturer
                          :(NSString *) modelHoist
                          :(NSString *) serialNoHoist
                          :(NSString *) ownerID
                          :(NSString *) lifting
                          :(NSString *) other
                          :(NSString *) testLoadsString
                          :(NSString *) proofLoadString
                          :(NSString *) loadRatingsString
                          :(NSString *) remarksLimitationsString
                          :(NSString *) footer
                          :(NSString *) nameAddress
                          :(NSString *) address
                          :(NSString *) expirationDate
                          :(NSString *) signature
                          :(NSString *) title
                          :(NSString *) inspectorName
                          :(NSString *) certificateNum
                          :(NSString *) date
                          :(NSString *) filePath
                          :(Inspection*) inspection
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

    [myImage drawInRect:CGRectMake(-110, -30, 250, 250)];
    [myImage drawInRect:CGRectMake(50, 150, 500, 500) blendMode:kCGBlendModeLighten alpha:.15f];
    
    //Border lines
    //left vertical line
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
    
    
    
    [titleAddress drawInRect:CGRectMake(95, 35, 270, 45) withFont:[UIFont systemFontOfSize:12.0]];
    [headerTitle drawInRect:CGRectMake(355, 35, 300, 50) withFont:[UIFont systemFontOfSize:12.0f]];
    
    //LINE 1
    [ownerString drawInRect:CGRectMake(50, 160, 500, 20) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    CGContextSetLineWidth(pdfContext, 1);
    
    CGContextSetStrokeColorWithColor(pdfContext, [UIColor blackColor].CGColor);
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 110, 175);
    CGContextAddLineToPoint(pdfContext, 550, 175);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 2
    [ownerAddressString drawInRect:CGRectMake(50, 190, 500 , 20) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 170, 205);
    CGContextAddLineToPoint(pdfContext, 550, 205);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 3
    [location drawInRect:CGRectMake(50, 220, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 120, 235);
    CGContextAddLineToPoint(pdfContext, 550, 235);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 4
    [description drawInRect:CGRectMake(50, 250, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 130, 265);
    CGContextAddLineToPoint(pdfContext, 260, 265);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 4 PART 2
    [ratedCapacity drawInRect:CGRectMake(255, 250, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 355, 265);
    CGContextAddLineToPoint(pdfContext, 550, 265);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 5
    [craneManafacturer drawInRect:CGRectMake(50, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 180, 295);
    CGContextAddLineToPoint(pdfContext, 265, 295);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //Crane Mfg
    [inspection.crane.mfg drawInRect:CGRectMake(180, 280, 230, 20) withFont:[UIFont systemFontOfSize:10.0f]];
    
    //LINE 6 Part 2
    /*
     [modelCrane drawInRect:CGRectMake(270, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
     
     CGContextBeginPath(pdfContext);
     CGContextMoveToPoint(pdfContext, 310, 295);
     CGContextAddLineToPoint(pdfContext, 400, 295);
     
     CGContextClosePath(pdfContext);
     CGContextDrawPath(pdfContext, kCGPathFillStroke);
     
     [txtHoistMdl.text drawInRect:CGRectMake(310, 280, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
     */
    
    //LINE 6 Part 3
    [serialNoCrane drawInRect:CGRectMake(410, 280, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 295);
    CGContextAddLineToPoint(pdfContext, 550, 295);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //Crane Srl
    [inspection.crane.craneSrl drawInRect:CGRectMake(470, 280, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 7
    [hoistManufacturer drawInRect:CGRectMake(50, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 170, 325);
    CGContextAddLineToPoint(pdfContext, 265, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //Hoist Mfg
    [inspection.crane.hoistMfg drawInRect:CGRectMake(170, 310, 230, 20) withFont:[UIFont systemFontOfSize:10.0f]];
    
    //LINE 7 Part 2
    [modelHoist drawInRect:CGRectMake(270, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 310, 325);
    CGContextAddLineToPoint(pdfContext, 400, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //Hoist Mdl
    [inspection.crane.hoistMdl drawInRect:CGRectMake(310, 310, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    
    //LINE 7 Part 3
    [serialNoHoist drawInRect:CGRectMake(410, 310, 230, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 325);
    CGContextAddLineToPoint(pdfContext, 550, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //Hoist Srl
    [inspection.crane.hoistSrl drawInRect:CGRectMake(470, 310, 230, 20) withFont:[UIFont systemFontOfSize:8.0f]];
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 470, 325);
    CGContextAddLineToPoint(pdfContext, 550, 325);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 8
    [ownerID drawInRect:CGRectMake(50, 340, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 230, 355);
    CGContextAddLineToPoint(pdfContext, 550, 355);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 9
    [testLoadsString drawInRect:CGRectMake(50, 370, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 340, 385);
    CGContextAddLineToPoint(pdfContext, 550, 385);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 10
    [proofLoadString drawInRect:CGRectMake(50, 400, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 210, 415);
    CGContextAddLineToPoint(pdfContext, 550, 415);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 11
    [loadRatingsString drawInRect:CGRectMake(50, 430, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 240, 445);
    CGContextAddLineToPoint(pdfContext, 550, 445);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    //LINE 12
    [remarksLimitationsString drawInRect:CGRectMake(50, 460, 500, 20) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 270, 475);
    CGContextAddLineToPoint(pdfContext, 550, 475);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 14
    [footer drawInRect:CGRectMake(50, 495, 500, 120) withFont:[UIFont systemFontOfSize:12.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
    
    //LINE 15
    [nameAddress drawInRect:CGRectMake(50, 565, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    //LINE 16
    [address drawInRect:CGRectMake(330, 565, 500, 120) withFont:[UIFont systemFontOfSize:11.0f]];
    
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
    
    //LINE 17
    [expirationDate drawInRect:CGRectMake(50, 630, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 140, 645);
    CGContextAddLineToPoint(pdfContext, 300, 645);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 17 PART 2
    [signature drawInRect:CGRectMake(330, 630, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 390, 645);
    CGContextAddLineToPoint(pdfContext, 550, 645);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    UIFont *font = [UIFont systemFontOfSize:12.0f];

    NSDictionary *dictionary = @{NSFontAttributeName : font};
    
    //LINE 18
    [title drawInRect:CGRectMake(50, 670, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 80, 685);
    CGContextAddLineToPoint(pdfContext, 170, 685);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 18 PART 2
    [inspectorName drawInRect:CGRectMake(330, 670, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 370, 685);
    CGContextAddLineToPoint(pdfContext, 550, 685);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 19
    [certificateNum drawInRect:CGRectMake(50, 710, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 165, 725);
    CGContextAddLineToPoint(pdfContext, 300, 725);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    //LINE 19 PART 2
    [date drawInRect:CGRectMake(330, 710, 500, 120) withFont:[UIFont systemFontOfSize:12.0f]];
    
    CGContextBeginPath(pdfContext);
    CGContextMoveToPoint(pdfContext, 365, 725);
    CGContextAddLineToPoint(pdfContext, 550, 725);
    
    CGContextClosePath(pdfContext);
    CGContextDrawPath(pdfContext, kCGPathFillStroke);
    
    
    //[self displayComposerSheet];
    // Clean up
    UIGraphicsPopContext();
    CGPDFContextEndPage(pdfContext);
    CGPDFContextClose(pdfContext);
    //release memory
    fileURL = nil;
    pdfContext = nil;
    myImage = nil;
}

//This text file that is written contains all the information that has been created: Customer Information; Crane Information; and Inspection Information
+ (void)  writeReport : (ItemListConditionStorage *) myConditionList
           Inspection : (Inspection*) inspection
        OverallRating : (NSString*) overallRating
           PartsArray : (NSArray*) myPartsArray
{
    NSMutableString *printString = [NSMutableString stringWithString:@""];
    NSMutableString *customerInfoResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionLeftColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionRightColumn = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescriptionRightResultsColumn = [NSMutableString stringWithString:@""];
    NSMutableString *partTitle = [NSMutableString stringWithString:@""];
    NSMutableString *partDeficiency = [NSMutableString stringWithString:@""];
    NSMutableString *partNotes = [NSMutableString stringWithString:@""];
    NSMutableString *deficientPartString = [NSMutableString stringWithString:@""];
    NSMutableString *footerLeft = [NSMutableString stringWithString:@""];
    NSMutableString *footerRight = [NSMutableString stringWithString:@""];
    NSMutableString *header = [NSMutableString stringWithString:@""];
    NSMutableString *craneDescription = [NSMutableString stringWithString:@""];
    //customer information titles and descriptions
    [printString appendString:@"Customer Information\n\n"];
    [printString appendString:[NSMutableString stringWithFormat:@"Customer Name:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Customer Contact:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Job Number:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Email Address:\n"]];
    [printString appendString:[NSString stringWithFormat:@"Customer Address:\n\n"]];
    //the customer information results
    //Customer - Name
    [customerInfoResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", inspection.customer.name]];
    //-Contact
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.customer.contact]];
    //-Job Number
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.jobNumber]];
    //-Email
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.customer.email]];
    //-Address
    [customerInfoResultsColumn appendString:[NSString stringWithFormat:@"%@\n\n", inspection.customer.address]];
    //Crane Description
    [craneDescription appendString:[NSString stringWithFormat:@"Crane Description: %@", inspection.crane.description]];
    //the crane description titles
    [craneDescriptionLeftColumn appendString:@"Overall Condition Rating:\n"];
    [craneDescriptionLeftColumn appendString:@"Crane Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Mfg:\n"];
    [craneDescriptionLeftColumn appendString:@"Hoist Model:\n"];
    //crane description results
    [craneDescriptionResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", overallRating]];
    //CraneMfg
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.mfg]];
    //HoistMfg
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.hoistMfg]];
    //HoistMdl
    [craneDescriptionResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.hoistMdl]];
    //crane description titles right column
    [craneDescriptionRightColumn appendString:@"\n\nCap:\n"];
    [craneDescriptionRightColumn appendString:@"Crane Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Hoist Srl:\n"];
    [craneDescriptionRightColumn appendString:@"Equip #:\n"];
    //creane description results
    //-Crane-Capacity
    [craneDescriptionRightResultsColumn appendString:[NSMutableString stringWithFormat:@"\n\n%@\n", inspection.crane.capacity]];
    //Crane Srl
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.craneSrl]];
    //Hoist Srl
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.hoistSrl]];
    //Equipment Number
    [craneDescriptionRightResultsColumn appendString:[NSString stringWithFormat:@"%@\n", inspection.crane.equipmentNumber]];
    //Technician Name
    [footerLeft appendString:[NSString stringWithFormat:@"Technician:%@\nDate: %@",inspection.technicianName, inspection.date]];
    //Customer Name
    [footerRight appendString:[NSString stringWithFormat:@"Customer:%@\nDate: %@",inspection.customer.name, inspection.date]];
    
    [header appendString:[NSString stringWithFormat:@"Silverstate Wire Rope and Rigging\n\n24-Hour Emergency Service\nSales - Service - Repair\nElectrical - Mechanical - Pneumatic\nCal-OSHA Accredited"]];
    
    int i = 0;
    
    for (Condition *myCondition in myConditionList.myConditions)
    {
        if (myCondition.applicable == NO)
        {
            if (myCondition.deficient == YES){
                [partDeficiency appendString:@"Failed\n"];
                [partNotes appendString:[NSString stringWithFormat:@"%d.  %@: %@\n",i + 1, myCondition.deficientPart, myCondition.notes]];
            }
            else if (myCondition.deficient==NO) {
                if (![myCondition.notes isEqualToString:@""])
                {
                    [partNotes appendString:[NSString stringWithFormat:@"%d.  %@\n",i + 1, myCondition.notes]];
                }
                [partDeficiency appendString:@"Passed\n"];
            }
        }
        else {
            [partDeficiency appendString:@"N/A\n"];
        }
        [partTitle appendString:[NSString stringWithFormat:@"%d. %@\n",i + 1, (NSString *)[myPartsArray objectAtIndex:i]]];
        i ++;
    }
    
    //Create the file
    
    NSError *error;
    
    //create file manager
    
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF",inspection.customer.name, inspection.crane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    //NSString *documentsDirectory = @"/Users/Developer/Documents";
    NSString *filePath = pdfFileName;
    //NSString *afilePath = [documentsDirectory stringByAppendingPathComponent:@"jobInfoArray.txt"];
    
    NSLog(@"string to write:%@", printString);
    
    [printString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self CreatePDFFile:printString
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
    //release memory
    
    printString = nil;
    customerInfoResultsColumn = nil;
    craneDescriptionLeftColumn = nil;
    craneDescriptionResultsColumn = nil;
    craneDescriptionRightColumn = nil;
    craneDescriptionRightResultsColumn = nil;
    filePath = nil;
    partDeficiency = nil;
    partTitle = nil;
    partNotes = nil;
    deficientPartString = nil;
    footerLeft = nil;
    footerRight = nil;
    header = nil;
    craneDescription = nil;
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
    [header drawInRect:CGRectMake(20, 20, 200, 200) withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    [printString drawInRect:CGRectMake(225, 20, 120 , 120) withFont:[UIFont systemFontOfSize:10.0f] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    [customerInfoResultsColumn drawInRect:CGRectMake(325, 20, 400, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescription drawInRect:CGRectMake(20, 120, 500, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionLeftColumn drawInRect:CGRectMake(20, 145, 120, 160) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionResultsColumn drawInRect:CGRectMake(140, 120, 150, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightColumn drawInRect:CGRectMake(300, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [craneDescriptionRightResultsColumn drawInRect:CGRectMake(410, 120, 120, 120) withFont:[UIFont systemFontOfSize:10.0f]];
    [partTitle drawInRect:CGRectMake(20, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partDeficiency drawInRect:CGRectMake(235, 220, 120, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [partNotes drawInRect:CGRectMake(310, 220, 220, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [deficientPartString drawInRect:CGRectMake(500, 220, 300, 700) withFont:[UIFont systemFontOfSize:8.0f]];
    [conditionRatingString drawInRect:CGRectMake(20, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerLeft drawInRect:CGRectMake(300, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    [footerRight drawInRect:CGRectMake(450, 700, 600, 70) withFont:[UIFont systemFontOfSize:8.0f]];
    // Clean up
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

+ (UIDocumentInteractionController *) DisplayPDFWithOverallRating : (Inspection *) inspection
{
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@.PDF", inspection.customer.name, inspection.crane.hoistSrl, dateNoSlashes];
    
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

+ (void)CreateCertificate : (Inspection*) inspection  {
    NSString *dateNoSlashes = [inspection.date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString* fileName = [NSString stringWithFormat:@"%@ %@ %@ Certificate.PDF", inspection.customer.name, inspection.crane.hoistSrl, dateNoSlashes];
    
    NSArray *arrayPaths =
    NSSearchPathForDirectoriesInDomains(
                                        NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    NSString *path = [arrayPaths objectAtIndex:0];
    NSString* pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    UIDocumentInteractionController *pdfViewController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pdfFileName]];
    
    [pdfViewController presentPreviewAnimated:NO];
    
    //disable the button certificate button so that we make sure there's no errant certificates being made
   // CreateCertificateButton.enabled = FALSE;
}





@end
