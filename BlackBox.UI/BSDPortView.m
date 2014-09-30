//
//  BSDPortView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import <QuartzCore/QuartzCore.h>

@implementation BSDPortView

- (instancetype)initWithName:(NSString *)name delegate:(id<BSDPortViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _delegate = delegate;
        _connectedPortViews = [NSMutableArray array];
        _portName = name;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1].CGColor;
    }
    
    return self;
}

- (void)handlePortConnectionStatusChangedNotification:(NSNotification *)notification
{
    NSNumber *object = notification.object;
    NSInteger state = object.integerValue;
    if (state > 1) {
        self.backgroundColor = [UIColor redColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)addConnectionToPortView:(BSDPortView *)portView
{
    if (![self.connectedPortViews containsObject:portView]) {
        [self.connectedPortViews addObject:portView];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = 1 - self.isSelected;
    [self.delegate tapInPortView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        __weak BSDPortView *weakself = self;
        CGRect newFrame;
        UIColor *newColor = nil;
        if (_selected) {
            newColor = [UIColor lightGrayColor];
            newFrame = CGRectInset(self.frame, -5, -5);
            
        }else{
            newColor = [UIColor whiteColor];
            newFrame = CGRectInset(self.frame, 5, 5);
        }
        
        [UIView animateWithDuration:0.2
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:1
                            options:0
                         animations:^{
                             weakself.frame = newFrame;
                             weakself.backgroundColor = newColor;
                         } completion:NULL];
    }

}





@end
