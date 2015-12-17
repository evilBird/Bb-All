//
//  BbBangObject.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBangObject.h"

@implementation BbBangObject

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
}

- (void)hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    [self.mainOutlet output:[BbBang bang]];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        return [BbBang bang];
    };
}

+ (NSString *)UIType
{
    return @"bang";
}

@end
