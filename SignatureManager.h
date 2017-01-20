//
//  SignatureManager.h
//  Inspection Form App
//
//  Created by adeiji on 1/20/17.
//
//

#import <Foundation/Foundation.h>
#import "IAConstants.h"

@interface SignatureManager : NSObject

// Save the signature image
- (void) saveSignatureFromImage : (UIImage *) image;
//Get the image path for the signature image
- (NSString *) documentsPathForFileName : (NSString *) name;
// Return the signature image
- (UIImage *) getSignature;

@end
