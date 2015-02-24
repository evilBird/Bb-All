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

@property (nonatomic,strong)    id                      theMessage;
@property (nonatomic,strong)    NSMutableArray          *messageQueue;

@end

@implementation BbMessage

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
    self.messageQueue = [NSMutableArray array];
    self.messageBuffer = [arguments toString];
    self.name = @"";
}

- (void)setMessageBuffer:(NSString *)messageBuffer
{
    _messageBuffer = messageBuffer;
    self.messageQueue = [BbMessageParser messageFromText:messageBuffer];
    self.creationArguments = [messageBuffer toArray];
}

/*
- (void)hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    __weak BbMessage *weakself = self;
    [self.messageQueue sendMessagesWithBlock:^(id message) {
        [weakself.mainOutlet output:message];
    }];
}
*/

- (id)outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    id hot = [hotInlet getValue];
    if ([hot isKindOfClass:[BbBang class]]) {
        [self.messageQueue sendMessagesWithBlock:^(id message) {
            [outlet output:message];
        }];
        
        return nil;
    }
    
    if ([hot isKindOfClass:[NSArray class]]) {
        NSArray *placeholderIndices = [self.messageQueue placeholderIndices];
        NSMutableArray *inputArray = hot;
        NSMutableArray *queueCopy = self.messageQueue.mutableCopy;
        for (NSArray *placeholderIndex in placeholderIndices) {
            NSUInteger queueIndex = [placeholderIndex.firstObject unsignedIntegerValue];
            NSUInteger arrayIndex = [placeholderIndex[1] unsignedIntegerValue];
            NSUInteger inputIndex = [placeholderIndex.lastObject unsignedIntegerValue] - 1;
            id toChange = queueCopy[queueIndex];
            if ([toChange isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrayCopy = [(NSArray *)toChange mutableCopy];
                arrayCopy[arrayIndex] = inputArray[inputIndex];
                queueCopy[queueIndex ] = arrayCopy;
            }
        }
        return queueCopy;
    }

    return nil;
}

+ (NSString *)UIType
{
    return @"msg";
}

@end
