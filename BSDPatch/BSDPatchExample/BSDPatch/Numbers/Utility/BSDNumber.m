//
//  BSDNumber.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumber.h"

@implementation BSDNumber

- (instancetype)initWithValue:(NSNumber *)value
{
    return [super initWithArguments:value];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"number";
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSNumber *val = self.hotInlet.value;
    if ([val isKindOfClass:[NSNumber class]]) {
        [self.mainOutlet output:val];
    }
}

@end
