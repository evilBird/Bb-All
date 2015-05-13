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

- (UIView *)makeMyView
{
    return [self makeMyViewWithFrame:CGRectMake(0, 0, 44, 44)];
}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    UIImageView *myView = [[UIImageView alloc]initWithFrame:frame];
    return myView;
}

@end
