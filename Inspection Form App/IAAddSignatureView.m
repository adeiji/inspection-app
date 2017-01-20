//
//  IAAddSignatureView.m
//  Inspection Form App
//
//  Created by adeiji on 1/17/17.
//
//

#import "IAAddSignatureView.h"

@implementation IAAddSignatureView {
    CGPoint lastPoint;
    BOOL swiped;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    swiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.mainImage];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    swiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.mainImage];
    
    UIGraphicsBeginImageContextWithOptions(self.mainImage.frame.size, NO, 1.0);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0 );
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:1.0];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!swiped) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1.0);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0);
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    UIGraphicsBeginImageContextWithOptions(self.mainImage.frame.size, NO, 1.0);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
}

- (void) createClearButton {
    self.clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 275, 50)];
    [self.clearButton setBackgroundColor:[UIColor colorWithRed:192.0f/255.0f green:57.0f/255.0f blue:43.0f/255.0f alpha:1.0]];
    [self.clearButton.layer setBorderWidth:0.0];
    [self.clearButton.layer setCornerRadius:5.0f];
    [self.clearButton setTitle:@"Reset" forState:UIControlStateNormal];
    [self.clearButton setCenter:CGPointMake(self.center.x, self.center.y + 150)];
    [self.clearButton addTarget:self action:@selector(clearGraphicContext) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void) createSaveButton {
    
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 275, 50)];
    [self.saveButton setBackgroundColor:[UIColor colorWithRed:38.0f/255.0f green:183.0f/255.0f blue:239.0f/255.0f alpha:1.0]];
    [self.saveButton.layer setBorderWidth:0.0f];
    [self.saveButton.layer setCornerRadius:5.0f];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setCenter:CGPointMake(self.center.x, self.center.y + 220)];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, (self.frame.size.height / 2) - 100)];
    self.tempDrawImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, (self.frame.size.height / 2) - 100)];
    [self.mainImage setBackgroundColor:[UIColor clearColor]];
    [self.tempDrawImage setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:self.mainImage];
    [self addSubview:self.tempDrawImage];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width, 100)];
    [instructionLabel setText:@"Enter your signature by using your finger or stylus above the line"];
    [instructionLabel setTextAlignment:NSTextAlignmentCenter];
    [instructionLabel setCenter:CGPointMake(self.center.x, self.center.y + 30)];
    [instructionLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [instructionLabel setTextColor:[UIColor blackColor]];
    
    [self addSubview:instructionLabel];
    
    [self createSaveButton];
    [self createClearButton];
    [self addSubview:self.clearButton];
    [self addSubview:self.saveButton];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, 50, self.center.y);
    CGContextAddLineToPoint(context, self.frame.size.width - 50, self.center.y);
    CGContextStrokePath(context);
}

- (void) clearGraphicContext {
    self.mainImage.image = nil;
}

@end
