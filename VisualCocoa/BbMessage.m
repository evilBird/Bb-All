//
//  BbMessage.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbMessage.h"
#import "BbMessageParser.h"
#import "NSInvocation+Bb.h"

@interface BbMessage ()

@property (nonatomic,strong)    id                      theMessage;
@property (nonatomic,strong)    NSMutableArray          *messageQueue;

@end

@implementation BbMessage

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObjects:@(BbValueType_Array),@(BbValueType_Bang), nil];
    }
    
    return nil;
}

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

- (void)hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    NSLog(@"bang!");
    __weak BbMessage *weakself = self;
    [self.messageQueue sendMessagesWithBlock:^(id message) {
        [weakself.mainOutlet output:message];
    }];
}

- (id)outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    id hot = [hotInlet getValue];
    
    if ([hot isKindOfClass:[BbBang class]]) {
        [self.messageQueue sendMessagesWithBlock:^(id message) {
            [outlet output:message];
        }];
        
        return nil;
    }
    
    
    NSMutableArray *inputArray = hot;
    
    if (!hot) {
        return nil;
    }
    
    if ([self executeCommandsFromInput:inputArray]) {
        return nil;
    }
    
    NSArray *placeholderIndices = [self.messageQueue placeholderIndices];
    if (placeholderIndices.count) {
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

#pragma mark - commands

- (void)setMessageBufferWithArgs:(id)args
{
    NSString *messageBuffer = nil;
    
    if (args) {
        messageBuffer = [args toString];
    }else{
        messageBuffer = @"";
    }
    
    self.messageBuffer = messageBuffer;
    [self.displayDelegate object:self didUpdate:self.messageBuffer];
}

- (void)addCommaToMessageBuffer
{
    NSString *messageBuffer = self.messageBuffer.copy;
    NSString *newMessageBuffer = [messageBuffer stringByAppendingString:@","];
    self.messageBuffer = newMessageBuffer;
    [self.displayDelegate object:self didUpdate:self.messageBuffer];
}

- (void)add2MessageBufferWithArgs:(id)args
{
    NSString *messageBuffer = nil;
    
    if (args) {
        messageBuffer = [NSString stringWithFormat:@" %@",[args toString]];
        
    }else{
        messageBuffer = @"";
    }
    
    NSString *newMessageBuffer = [self.messageBuffer stringByAppendingString:messageBuffer];
    self.messageBuffer = newMessageBuffer;
    [self.displayDelegate object:self didUpdate:self.messageBuffer];
}

- (BOOL)executeCommandsFromInput:(NSArray *)input
{
    if (!input) {
        return NO;
    }
    NSMutableArray *inputCopy = input.mutableCopy;
    
    NSString *selectorKey = [inputCopy.firstObject toString];
    
    NSDictionary *selectorLookup = @{@"set":@"setMessageBufferWithArgs:",
                                     @"addComma":@"addCommaToMessageBuffer",
                                     @"add2":@"add2MessageBufferWithArgs:"
                                     };
    
    if (![selectorLookup.allKeys containsObject:selectorKey]) {
        return NO;
    }
    
    NSString *selectorName = [selectorLookup valueForKey:selectorKey];
    
    SEL selector = NSSelectorFromString(selectorName);
    
    if (![self respondsToSelector:selector]) {
        return NO;
    }
    
    id args = nil;
    if (inputCopy.count > 1) {
        [inputCopy removeObjectAtIndex:0];
        args = inputCopy;
    }
    
    [self performSelector:selector withObject:args];
    
    return YES;
}



- (void)tearDown
{
    [super tearDown];
    self.displayDelegate = nil;
}

@end
