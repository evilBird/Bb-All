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
    //self.selected = 1 - self.isSelected;
    //[self.delegate tapInPortView:self];
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        
        if (_selected) {
            self.backgroundColor = [UIColor lightGrayColor];
            CGRect newFrame = CGRectInset(self.frame, -5, -5);
            self.frame = newFrame;
            
        }else{
            self.backgroundColor = [UIColor whiteColor];
            CGRect newFrame = CGRectInset(self.frame, 5, 5);
            self.frame = newFrame;
        }
    }

}





@end
