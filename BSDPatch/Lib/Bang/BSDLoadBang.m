//
//  BSDLoadBang.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLoadBang.h"

@implementation BSDLoadBang
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"loadbang";
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleLoadBangNotification:)
                                                name:kLoadBangNotification
                                              object:nil];
}

- (void)loadBang
{
    [self.mainOutlet output:[BSDBang bang]];
}

- (void)parentPatchFinishedLoading
{
    [self.mainOutlet output:[BSDBang bang]];
}

- (void)handleLoadBangNotification:(NSNotification *)notification
{
    [self loadBang];
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

@end
