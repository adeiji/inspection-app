//
//  AutographViewController.m
//  Inspection Form App
//
//  Created by Developer on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AutographViewController.h"
#import "T1Autograph.h"
#import <QuartzCore/QuartzCore.h>

@interface AutographViewController ()

@end

@implementation AutographViewController
@synthesize autograph;
@synthesize secondAutograph;
@synthesize autographModal;
@synthesize outputImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.25 alpha:1];
    CGFloat padding = self.view.frame.size.width/15;
    // Make a view for the signature
    
	UIView *autographView = [[UIView alloc] initWithFrame:CGRectMake(padding, 50, 280, 160)];
	autographView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	autographView.layer.borderWidth = 3;
	autographView.layer.cornerRadius = 10;
	[autographView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:autographView];
    
    // Initialize Autograph library
	self.autograph = [T1Autograph autographWithView:autographView delegate:self];
	
	// to remove the watermark, get a license code from Ten One, and enter it here	
	[autograph setLicenseCode:@"4fabb271f7d93f07346bd02cec7a1ebe10ab7bec"];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[clearButton setFrame:CGRectMake(padding, 230, 130,30)];
	[clearButton setTitle:@"Clear" forState:UIControlStateNormal];
	[clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[clearButton addTarget:self action:@selector(clearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:clearButton]; 
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[doneButton setFrame:CGRectMake(150 + padding, 230, 130,30)];
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	UIButton *showModalButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[showModalButton setFrame:CGRectMake(padding, 280, 130,30)];
	[showModalButton setTitle:@"Show Modal" forState:UIControlStateNormal];
	[showModalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[showModalButton addTarget:self action:@selector(showModalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:showModalButton]; 
    
    UIView *secondAutographView = [[UIView alloc] initWithFrame:CGRectMake(padding, 400, 280, 160)];
	secondAutographView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	secondAutographView.layer.borderWidth = 3;
	secondAutographView.layer.cornerRadius = 10;
	[secondAutographView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:secondAutographView];
    
    // Initialize Autograph library
	self.secondAutograph = [T1Autograph autographWithView:secondAutographView delegate:self];
    
    UIButton *secondClearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[secondClearButton setFrame:CGRectMake(padding, 580, 130,30)];
	[secondClearButton setTitle:@"Clear" forState:UIControlStateNormal];
	[secondClearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[secondClearButton addTarget:self action:@selector(secondClearButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:secondClearButton]; 
	
	UIButton *secondDoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[secondDoneButton setFrame:CGRectMake(150 + padding, 580, 130,30)];
	[secondDoneButton setTitle:@"Done" forState:UIControlStateNormal];
	[secondDoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[secondDoneButton addTarget:self action:@selector(secondDoneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:secondDoneButton];
	
	UIButton *secondShowModalButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];		//initWithFrame:CGRectMake(50, 300, 200,60) ];
	[secondShowModalButton setFrame:CGRectMake(padding, 630, 130,30)];
	[secondShowModalButton setTitle:@"Show Modal" forState:UIControlStateNormal];
	[secondShowModalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[secondShowModalButton addTarget:self action:@selector(secondShowModalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:secondShowModalButton]; 

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)clearButtonAction:(id)sender {
	[autograph reset:self];
}
-(IBAction)secondClearButtonAction:(id)sender {
	[secondAutograph reset:self];
}

-(IBAction)doneButtonAction:(id)sender {
	[autograph done:self];
	[autograph reset:self];
}

-(IBAction)secondDoneButtonAction:(id)sender {
	[secondAutograph done:self];
	[secondAutograph reset:self];
}
-(IBAction)showModalButtonAction:(id)sender {
	
	// Show modal view with message above signature line
	self.autographModal = [T1Autograph autographWithDelegate:self modalDisplayString:@"I hereby grant ReFreshers Inc. permission to recycle the socks in my home for the next 200 years."];
	
	// Show modal view with no message
	//	autographModal = [T1Autograph autographWithDelegate:self modalDisplayString:nil];
	
	// Remove the watermark
	[autographModal setLicenseCode:@"4fabb271f7d93f07346bd02cec7a1ebe10ab7bec"];
	
	// any optional configuration done here
	[autographModal setShowDate:YES];
	[autographModal setStrokeColor:[UIColor lightGrayColor]];
}

-(IBAction)secondShowModalButtonAction:(id)sender {
	
	// Show modal view with message above signature line
	self.autographModal = [T1Autograph autographWithDelegate:self modalDisplayString:@"I hereby grant ReFreshers Inc. permission to recycle the socks in my home for the next 200 years."];
	
	// Show modal view with no message
	//	autographModal = [T1Autograph autographWithDelegate:self modalDisplayString:nil];
	
	// Remove the watermark
	[autographModal setLicenseCode:@"4fabb271f7d93f07346bd02cec7a1ebe10ab7bec"];
	
	// any optional configuration done here
	[autographModal setShowDate:YES];
	[autographModal setStrokeColor:[UIColor lightGrayColor]];
}


// Delegate Methods

-(void)didDismissModalView {
	NSLog(@"Autograph modal signature has been cancelled");
}

-(void)autographDidCompleteWithNoData {
	NSLog(@"User pressed the done button without signing");
}

-(void)autograph:(T1Autograph *)autograph didCompleteWithSignature:(T1Signature *)signature {
	
	// Log information about the signature
	NSLog(@"Autograph signature completed.");
	NSLog(@"Hash value: %@",signature.hashString);
	NSLog(@"Frame: %@",NSStringFromCGRect(signature.frame));	// can be used to place a signature image directly over original signature	
	
	// display the signature
	[outputImage removeFromSuperview];
	self.outputImage = [signature imageView];
	[outputImage setFrame:CGRectMake(self.view.frame.size.width/15, 700, outputImage.frame.size.width, outputImage.frame.size.height)];
	[self.view addSubview:outputImage];
	
	// you can access the raw image data like this:
	// UIImage *img = [UIImage imageWithData:signature.imageData];
	
	// you can access the raw data points like this:
	// NSArray *rawPoints = signature.rawPoints;
	
	// If the modal view was used, release it.  You won't need to do this if you're not using the modal.
	if (autographModal!=nil) {
		autographModal = nil;
	}
	
}

// Standard View Controller stuff

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

@end
