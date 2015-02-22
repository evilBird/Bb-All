//
//  BbMessage.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbMessage.h"

@interface BbMessage ()

@end

@implementation BbMessage

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.messageBuffer = arguments;
    self.name = @"";
}

- (void)setMessageBuffer:(id)messageBuffer
{
    _messageBuffer = messageBuffer;
    self.creationArguments = messageBuffer;
}

- (void)hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    [inlet input:self.messageBuffer];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    __weak BbMessage *weakself = self;
    return ^(id hotValue,NSArray *inlets){
        return [weakself messageBuffer];
    };
}

+ (NSString *)UIType
{
    return @"msg";
}

@end
