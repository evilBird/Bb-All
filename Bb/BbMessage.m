//
//  BbMessage.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbMessage.h"
#import "BbMessageParser.h"

@interface BbMessage ()

@property (nonatomic,strong)NSMutableArray *messageQueue;

@end

@implementation BbMessage

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.messageQueue = [NSMutableArray array];
    self.name = @"";
}

- (void)setMessageWithText:(NSString *)text
{
    self.creationArguments = [text toArray];
    self.messageQueue = [BbMessageParser messageFromText:text];
}

- (void)hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    __weak BbMessage *weakself = self;
    [self.messageQueue sendMessagesWithBlock:^(id message) {
        [weakself.mainOutlet output:message];
    }];
}

+ (NSString *)UIType
{
    return @"msg";
}

@end
