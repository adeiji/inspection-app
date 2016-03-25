//
//  FirstTimeOpeningViewController.m
//  Inspection Form App
//
//  Created by adeiji on 3/25/16.
//
//

#import "FirstTimeOpeningViewController.h"
#import "SyncManager.h"

@interface FirstTimeOpeningViewController ()

@end

@implementation FirstTimeOpeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)downloadInspectionDetailsButtonPressed:(id)sender {
    [SyncManager getAllInspectionDetails];
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
