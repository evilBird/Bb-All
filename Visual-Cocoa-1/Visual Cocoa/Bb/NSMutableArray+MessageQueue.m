//
//  NSMutableArray+MessageQueue.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSMutableArray+MessageQueue.h"
#import "BbMessageParser.h"

@implementation NSMutableArray (MessageQueue)

- (BOOL)isEmpty
{
    return (self.count == 0);
}

- (void)sendMessagesWithBlock:(void(^)(id message))block
{
    for (id aMessage in self) {
        block(aMessage);
    }
}

- (NSArray *)placeholderIndices
{
    return [self placeholderIndicesFirstIndex:0];
}

- (NSArray *)placeholderIndicesFirstIndex:(NSUInteger)firstIndex
{
    NSMutableArray *result = nil;
    NSUInteger argIndex = 0;
    for (id aMessage in self) {
        NSArray *substitutionSet = nil;
        if ([aMessage isKindOfClass:[NSString class]]) {
            NSString *messageString = aMessage;
            NSRange dollarRange = [messageString rangeOfString:@"$"];
            if (dollarRange.length && dollarRange.location == 0) {
                NSMutableString *messageStringCopy = [NSMutableString stringWithString:messageString];
                [messageStringCopy deleteCharactersInRange:dollarRange];
                id value = [BbMessageParser setTypeForString:messageStringCopy];
                if ([value isKindOfClass:[NSNumber class]]) {
                    //format for substiution set is
                    //@[messageIndex(0 based), argIndex(0 based), inputIndex(1 based)]
                    substitutionSet = @[@(firstIndex),@(argIndex),value];
                    
                    if (!result) {
                        result = [NSMutableArray array];
                    }
                    
                    [result addObject:substitutionSet];
                }
            }
        }else if ([aMessage isKindOfClass:[NSArray class]]){
            NSMutableArray *messageArray = [(NSArray *)aMessage mutableCopy];
            NSArray *indices = [messageArray placeholderIndicesFirstIndex:argIndex];
            if (!result) {
                result = [NSMutableArray array];
            }
            
            [result addObjectsFromArray:indices];
        }
        
        argIndex++;
    }
    
    return result;
}

@end

