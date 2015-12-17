//
//  BbPortProxy.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbProxyPort.h"

@implementation BbProxyPort

- (void)setupWithArguments:(id)arguments {}
- (void)setParentPort:(BbPort *)parentPort
{
    _parentPort = parentPort;
}

- (NSUInteger)index
{
    return 0;
}

@end


@implementation BbProxyInlet

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
}

- (void)setParentPort:(BbPort *)parentPort
{
    [super setParentPort:parentPort];
    
    if ([parentPort isKindOfClass:[BbInlet class]]) {
        [self observeInlet:(BbInlet *)parentPort];
    }
}

- (id)outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    return [hotInlet getValue];
}

+ (NSString *)UIType
{
    return @"inlet";
}

@end


@implementation BbProxyOutlet

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
}

- (void)setParentPort:(BbPort *)parentPort
{
    [super setParentPort:parentPort];
}

- (id)outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    BbOutlet *parent = (BbOutlet *)self.parentPort;
    [parent output:[hotInlet getValue]];
    return nil;
}

+ (NSString *)UIType
{
    return @"outlet";
}

@end