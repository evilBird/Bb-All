//
//  BSD2WayPort.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/6/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSD2WayPort.h"

@implementation BSD2WayPort

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"two way port";
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self.mainOutlet output:[BSDBang bang]];
    }
}

- (void)calculateOutput
{
    id value = self.hotInlet.value;
    [self.mainOutlet output:value];
}

@end
