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

- (void)parentPatchFinishedLoading
{
    [self.mainOutlet output:[BSDBang bang]];
}

- (void)handleLoadBangNotification:(NSNotification *)notification
{
    NSString *objectId = notification.object;
    if ([objectId hash] == [[self objectId]hash]) {
        [self parentPatchFinishedLoading];
    }
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
