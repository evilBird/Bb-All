//
//  BSDLabel.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLabel.h"

@implementation BSDLabel

- (instancetype)initWithSuperview:(UIView *)superview
{
    return [super initWithArguments:superview];
}

- (NSString *)displayName
{
    return @"label";
}

- (UIView *)view
{
    UILabel *myView = self.viewInlet.value;
    if (!myView) {
        myView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 88, 44)];
        myView.backgroundColor = [UIColor clearColor];
        myView.textAlignment = NSTextAlignmentLeft;
        myView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.viewInlet.value = myView;
    }
    
    return myView;
}

@end
