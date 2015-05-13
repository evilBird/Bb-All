//
//  BSDButton.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDButton.h"

@implementation BSDButton

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"button";

}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    UIButton *myView = [[UIButton alloc]initWithFrame:frame];
    myView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    myView.tintColor = [UIColor colorWithWhite:0.5 alpha:1];
    [myView setTitle:@"button" forState:UIControlStateNormal];
    [myView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [myView setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateHighlighted];
    [myView addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
    return myView;
}

- (void)handleAction:(id)sender
{
    [self.eventOutlet output:[BSDBang bang]];
}

@end
