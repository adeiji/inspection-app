//
//  SignatureManager.m
//  Inspection Form App
//
//  Created by adeiji on 1/20/17.
//
//

#import "SignatureManager.h"

@implementation SignatureManager

- (void) saveSignatureFromImage : (UIImage *) image {
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [self documentsPathForFileName:SIGNATURE_IMAGE_FILENAME];
    [imageData writeToFile:imagePath atomically:YES];
    [[NSUserDefaults standardUserDefaults] setObject:SIGNATURE_IMAGE_FILENAME forKey:SIGNATURE_USER_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

//Get the image path for the signature image
- (NSString *) documentsPathForFileName : (NSString *) name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (UIImage *) getSignature {
    
    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:SIGNATURE_USER_DEFAULTS_KEY];
    if (imagePath) {
        NSString *fullImagePath = [self documentsPathForFileName:SIGNATURE_IMAGE_FILENAME];
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:fullImagePath]];
    }
    
    return nil;
}


@end
