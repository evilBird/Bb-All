//
//  BSDLabel.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLabel.h"

@implementation BSDLabel

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (NSString *)displayName
{
    return @"label";
}

- (UIView *)makeMyView
{
    return [self makeMyViewWithFrame:CGRectMake(0, 0, 88, 22)];
}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    UILabel *myView = [[UILabel alloc]initWithFrame:frame];
    return myView;
}
@end
