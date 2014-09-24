//
//  BSDImageView.m
//  VideoBlurExample
//
//  Created by Travis Henspeter on 8/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDImageView.h"

@implementation BSDImageView

- (instancetype)initWithSuperview:(UIView *)superview;
{
    return [super initWithArguments:superview];
}

- (NSString *)displayName
{
    return @"image view";
}

- (UIView *)view
{
    UIImageView *myView = self.viewInlet.value;
    if (!myView) {
        myView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 88, 44)];
        self.viewInlet.value = myView;
    }
    
    return myView;
}

@end
