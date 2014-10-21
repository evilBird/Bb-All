//
//  BSDHSlider.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/21/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDHSlider.h"

@interface BSDHSlider ()

{
    BOOL isActive;
    NSValue *initPoint;
}

@property (nonatomic,strong)UIView *handle;

@end

@implementation BSDHSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.className = @"BSDNumber";
        self.boxClassString = @"BSDHSlider";
        _displayedValue = 0.5;
        self.defaultColor = [UIColor whiteColor];
        self.selectedColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.backgroundColor = self.defaultColor;
        self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        self.layer.borderWidth = 1;
        CGRect handleFrame = self.bounds;
        handleFrame.size.width *= 0.1;
        handleFrame.origin.x = CGRectGetMidX(self.bounds) - CGRectGetWidth(handleFrame) * 0.5;
        _handle = [[UIView alloc]initWithFrame:handleFrame];
        _handle.backgroundColor = [UIColor blackColor];
        [self addSubview:_handle];
        initPoint = nil;
    }
    
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint loc = [touches.allObjects.lastObject locationInView:self];
    UIView *theView = [self hitTest:loc withEvent:event];
    if (theView == self.handle) {
        initPoint = [NSValue valueWithCGPoint:loc];
        //self.panGesture.enabled = NO;
    }else{
        initPoint = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (initPoint) {
        CGPoint loc = [touches.allObjects.lastObject locationInView:self];
        self.displayedValue = loc.x/self.bounds.size.width;
        CGRect frame = self.handle.frame;
        frame.origin.x = self.bounds.size.width * _displayedValue - frame.size.width * 0.5;
        self.handle.frame = frame;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.panGesture.enabled = YES;

}

- (void)handlePan:(id)sender
{
    UIPanGestureRecognizer *recognizer = sender;
    CGPoint loc = [recognizer locationInView:self.superview];
    if (selectedPort == nil && initPoint == nil) {
        self.center = loc;
        [self.delegate boxDidMove:self];
    }else{
        
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
            {
                
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                [self.delegate box:self portView:selectedPort drawLineToPoint:loc];
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                [self.delegate box:self portView:selectedPort endedAtPoint:loc];
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    initPoint = nil;
    self.panGesture.enabled = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    NSNumber *val = changeInfo[@"value"];
    if (val && !initPoint) {
        
        self.displayedValue = val.doubleValue;
    }
}

- (void)setDisplayedValue:(CGFloat)displayedValue
{
    if (displayedValue > 1) {
        _displayedValue = 1;
    }else if (displayedValue < 0){
        _displayedValue = 0;
    }else{
        _displayedValue = displayedValue;
    }
    
    NSLog(@"displayed val: %f",displayedValue);
    //CGRect frame = self.handle.frame;
    //frame.origin.x = self.bounds.size.width * _displayedValue - frame.size.width * 0.5;
    //self.handle.frame = frame;
    [[self.object hotInlet]input:@(displayedValue)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}
*/
@end
