//
//  LoginViewController.m
//  Inspection Form App
//
//  Created by adeiji on 2/22/16.
//
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "Inspection_Form_App-Swift.h"

@implementation LoginViewController

NSString *const PASSWORD = @"sswr";

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {

    }
    
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    self.borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.borderView.layer.borderWidth = 1.0;
}
- (IBAction)loginUser:(id)sender {
    if ([self canProceed]) {
        [[IAFirebaseCraneInspectionDetailsManager new] getUserWithUsername:_txtUsername.text completion:^(NSDictionary<NSString *,id> * _Nullable user) {
            if (!user) {
                [self showAlertViewWithMessage:@"There is no user with this name.  Please try again, or click create account"];
            } else {
                [self userSignedIn];
                [UtilityFunctions saveUserWithName:user[@"username"] userId:user[@"id"]];
            }
        }];
    } else {
        [self showAlertViewWithMessage:@""];
    }
}

- (void) showAlertViewWithMessage : (NSString *) message {    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Login Credentials" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL) canProceed {
    if (![[_txtUsername.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && _txtUsername.text.length > 2) {
        return true;
    }

    [self showAlertViewWithMessage:@"Please Enter a Valid Name"];
    return false;
}

- (IBAction)createAccount:(id)sender {
    if ([self canProceed]) {
        [[IAFirebaseCraneInspectionDetailsManager new] checkIfUsernameExistsWithUsername:_txtUsername.text completion:^(NSString * _Nullable success) {
            if (success) {
                NSString *userId = [[IAFirebaseCraneInspectionDetailsManager new] addUserWithName:_txtUsername.text];
                [UtilityFunctions saveUserWithName:_txtUsername.text.lowercaseString userId:userId];
                [self userSignedIn];
            } else {
                [self showAlertViewWithMessage:@"Sorry, that name already exists.  Please login with that name or try a different name."];
            }
        }];
    } else {
        [self showAlertViewWithMessage:@"Please Enter a Valid Name"];
    }
}

- (void) userSignedIn {    
    [self.navigationController popToRootViewControllerAnimated:true];
}

@end
