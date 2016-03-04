//
//  LoginViewController.m
//  Inspection Form App
//
//  Created by adeiji on 2/22/16.
//
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

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
        [PFUser logInWithUsernameInBackground:_txtUsername.text password:PASSWORD block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (user != nil && !error) {
                [self userSignedIn];
            }
            else {
                [self showAlertViewWithMessage:error.userInfo[@"error"]];
            }
        }];
    } else {
        [self showAlertViewWithMessage:@""];
    }
}

- (void) showAlertViewWithMessage : (NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Login Credentials" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
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
        PFUser *user = [PFUser new];
        NSString *username = [_txtUsername.text lowercaseString];
        username = [_txtUsername.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        user.username = username;
        user.password = PASSWORD;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded && !error) {
                [self userSignedIn];
            }
            else {
                [self showAlertViewWithMessage:error.userInfo[@"error"]];
            }
        }];
        [user signUpInBackgroundWithTarget:self selector:@selector(userSignedIn)];
    } else {
        [self showAlertViewWithMessage:@"Please Enter a Valid Name"];
    }
}

- (void) userSignedIn {
    [self.navigationController popToRootViewControllerAnimated:true];
}


@end
