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
        self.defaultColor = [UIColor colorWithWhite:0.93 alpha:1];
        self.selectedColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.backgroundColor = self.defaultColor;
        self.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        self.layer.borderWidth = 1;
        CGRect handleFrame = self.bounds;
        handleFrame.size.width *= 0.05;
        handleFrame.origin.x = [self xOriginForFrame:handleFrame value:0.5];
        _handle = [[UIView alloc]initWithFrame:handleFrame];
        _handle.backgroundColor = [UIColor blackColor];
        [self addSubview:_handle];
        initPoint = nil;
    }
    
    return self;
}

- (CGFloat)xOriginForFrame:(CGRect)frame value:(CGFloat)value
{
    if (!self.inletViews) {
        return CGRectGetMidX(self.bounds) - CGRectGetWidth(frame);
    }
    
    CGRect portFrame = [(UIView *)self.inletViews.firstObject frame];
    CGFloat minOriginX = CGRectGetMaxX(portFrame);
    CGFloat minX = minOriginX + CGRectGetWidth(frame)/2;
    CGFloat maxX = CGRectGetMaxX(self.bounds) - CGRectGetWidth(frame)/2;
    CGFloat range =  maxX - minX;
    return range * value + minOriginX;
}

- (CGFloat)valueForX:(CGFloat)x
{
    CGRect portFrame = [(UIView *)self.inletViews.firstObject frame];
    CGFloat minOriginX = CGRectGetMaxX(portFrame);
    CGFloat maxX = CGRectGetMaxX(self.bounds) - CGRectGetWidth(self.handle.frame);
    CGFloat range =  maxX - minOriginX;
    CGFloat value = (x - minOriginX)/range;
    
    if (value > 1) {
        return 1.0;
    }
    if (value < 0) {
        return 0.0;
    }
    
    return (x - minOriginX)/range;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    initPoint = nil;
    CGPoint loc = [touches.allObjects.lastObject locationInView:self];
    UIView *theView = [self hitTest:loc withEvent:event];
    if (theView == self.handle) {
        initPoint = [NSValue valueWithCGPoint:loc];
    }else{
        initPoint = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    initPoint = nil;
}

- (void)handlePan:(id)sender
{
    UIPanGestureRecognizer *recognizer = sender;
    CGPoint loc = [recognizer locationInView:self.superview];

    if (initPoint && !selectedPort) {
        
        switch (recognizer.state) {
            case UIGestureRecognizerStateChanged:
            {
                CGPoint loc = [recognizer locationInView:self];
                self.displayedValue = [self valueForX:loc.x];
                CGRect frame = self.handle.frame;
                frame.origin.x = [self xOriginForFrame:frame value:self.displayedValue];
                self.handle.frame = frame;
            }
                break;
                
            default:
                break;
        }
        
        return;
    }
    if (selectedPort == nil) {
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


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    NSNumber *val = changeInfo[@"value"];
    if (val) {
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
    
    if (self.panGesture.state > 0){
        [[self.object hotInlet]input:@(displayedValue)];
        return;
    }
    
    CGRect handleFrame = self.handle.frame;
    handleFrame.origin.x = [self xOriginForFrame:handleFrame value:_displayedValue];
    self.handle.frame = handleFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}
*/
@end
