//
//  BSDBangBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBangControlBox.h"
#import "BSDPatch.h"

@interface BSDBangControlBox ()


@end

@implementation BSDBangControlBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDBangBox";
        [self makeObjectInstance];
        self.boxClassString = @"BSDBangControlBox";

        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        _defaultCenterColor = [UIColor colorWithWhite:0.8 alpha:1];
        _highlightCenterColor = [UIColor colorWithWhite:0.55 alpha:1];
        _currentCenterColor = _defaultCenterColor;
    }
    return self;
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
        
        [self doHighlight];
        __weak BSDBangControlBox *weakself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakself endHighlight];
        });
    }
}

- (void)senderValueChanged:(id)value
{

}

- (void)doHighlight
{
    self.currentCenterColor = self.highlightCenterColor;
}

- (void)endHighlight
{
    self.currentCenterColor = self.defaultCenterColor;
}

- (void)setCurrentCenterColor:(UIColor *)currentCenterColor
{
    _currentCenterColor = currentCenterColor;
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        
        [[self.object hotInlet]input:[BSDBang bang]];
        //[self doHighlight];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        //[self endHighlight];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        
        //[self endHighlight];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 6, 6)];
    [self.currentCenterColor setFill];
    [path fill];
}

@end
