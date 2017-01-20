//
//  IAAddSignatureViewController.m
//  Inspection Form App
//
//  Created by adeiji on 1/17/17.
//
//

#import "IAAddSignatureViewController.h"

@interface IAAddSignatureViewController ()

@end

@implementation IAAddSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.signatureView.saveButton addTarget:self action:@selector(saveSignature) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveSignature {
    SignatureManager *signatureManager = [SignatureManager new];
    
    if (self.signatureView.mainImage.image != nil)
    {
        [signatureManager saveSignatureFromImage:self.signatureView.mainImage.image];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Signature Saved" message:@"The Signature Was Saved Successfully!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Signature" message:@"Please Write Your Signature" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okayAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
