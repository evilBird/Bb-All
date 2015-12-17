//
//  BSDAny2Array.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAny2Array.h"

@implementation BSDAny2Array

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"any2array";
    
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    
    if (!hot) {
        return;
    }
    
    NSArray *output = [NSArray arrayWithObject:hot];
    [self.mainOutlet output:output];
}

@end
