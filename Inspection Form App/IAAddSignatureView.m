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
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
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
        UIGraphicsBeginImageContext(self.frame.size);
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

    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.mainImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, (self.frame.size.height / 2) - 100)];
    self.tempDrawImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, (self.frame.size.height / 2) - 100)];
    [self addSubview:self.mainImage];
    [self addSubview:self.tempDrawImage];
    
    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width, 100)];
    [instructionLabel setText:@"Enter your signature by using your finger or stylus above the line"];
    [instructionLabel setTextAlignment:NSTextAlignmentCenter];
    [instructionLabel setCenter:CGPointMake(self.center.x, self.center.y + 30)];
    [instructionLabel setFont:[UIFont systemFontOfSize:25.0]];
    [instructionLabel setTextColor:[UIColor blackColor]];
    
    [self addSubview:instructionLabel];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, 50, self.center.y);
    CGContextAddLineToPoint(context, self.frame.size.width - 50, self.center.y);
    CGContextStrokePath(context);
}

@end
