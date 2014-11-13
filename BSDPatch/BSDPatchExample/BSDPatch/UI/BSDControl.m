//
//  BSDControl.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDControl.h"

@implementation BSDControl

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    
    self.eventOutlet = [[BSDOutlet alloc]init];
    self.eventOutlet.name = @"event outlet";
    [self addPort:self.eventOutlet];
}

- (void)handleAction:(id)sender
{
    
}

@end
