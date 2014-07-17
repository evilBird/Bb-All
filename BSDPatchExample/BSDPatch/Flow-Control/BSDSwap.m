//
//  BSDSwap.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSwap.h"

@implementation BSDSwap

- (void)setupWithArguments:(id)arguments
{
    self.name = @"swap";
    BSDOutlet *rightOutlet = [[BSDOutlet alloc]init];
    rightOutlet.name = @"right";
    [self addPort:rightOutlet];
}

- (void)calculateOutput
{
    BSDOutlet *rightOutlet = [self outletNamed:@"right"];
    rightOutlet.value = self.hotInlet.value;
    self.mainOutlet.value = self.coldInlet.value;
}

@end
