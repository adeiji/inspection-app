//
//  InspectionsViewController.m
//  Inspection Form App
//
//  Created by adeiji on 2/24/16.
//
//

#import "InspectionsViewController.h"


@interface InspectionsViewController ()

@end

@implementation InspectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _inspections = [[IACraneInspectionDetailsManager sharedManager] getAllInspectedCranes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
