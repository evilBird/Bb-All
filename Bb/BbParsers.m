//
//  BbParsers.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/23/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbParsers.h"
#import "NSScanner+Bb.h"
#import "NSMutableString+Bb.h"

@implementation BbDescription
@end

@implementation BbObjectDescription
@end

@implementation BbConnectionDescription

- (NSString *)textDescription
{
    NSMutableString *desc = [NSMutableString newDescription];
    [desc tabCt:self.ancestors];
    [desc appendThenSpace:@"#X"];
    [desc appendThenSpace:@"connect"];
    [desc appendThenSpace:@(self.senderObjectIndex)];
    [desc appendThenSpace:@(self.senderPortIndex)];
    [desc appendThenSpace:@(self.receiverObjectIndex)];
    [desc appendThenSpace:@(self.receiverPortIndex)];
    [desc semiColon];
    [desc lineBreak];
    
    return desc;
}


+ (NSUInteger)connectionIdParent:(NSUInteger)parentId
                        senderId:(NSUInteger)senderId
                        outletId:(NSUInteger)outletId
                      receiverId:(NSUInteger)receiverId
                         inletId:(NSUInteger)inletId
{
    return ((parentId/1000) + (senderId/1000 + outletId/1000) + (receiverId/1000 + inletId/1000))/1000;
}

- (NSUInteger)connectionId
{
    return [BbConnectionDescription connectionIdParent:self.parentId
                                              senderId:self.senderId
                                              outletId:self.senderPortId
                                            receiverId:self.receiverId
                                               inletId:self.receiverPortId];
}

@end

@implementation BbBasicParser

+ (NSArray *)descriptionsWithText:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K > 0",@"length"];
    NSArray *lines = [components filteredArrayUsingPredicate:pred];
    
    NSMutableArray *descriptions = nil;
    for (NSString *line in lines) {
        BbDescription *desc = [BbBasicParser descriptionWithText:line];
        if (desc) {
            if (!descriptions) {
                descriptions = [NSMutableArray array];
            }
            
            [descriptions addObject:desc];
        }
    }
    
    return descriptions;
}



+ (BbDescription *)descriptionWithText:(NSString *)text
{
    return [BbBasicParser parseLine:text];
}

+ (BbDescription *)parseLine:(NSString *)line
{
    BbDescription *description = [[BbObjectDescription alloc]init];
    NSScanner *scanner = [NSScanner scannerWithString:line];
    description.stackIndex = [NSScanner scanStackIndex:&scanner];
    description.stackInstruction = [NSScanner scanStackInstruction:&scanner];
    description.UIType = [NSScanner scanUIType:&scanner];
    
    if ([description.UIType isEqualToString:@"restore"]) {
        return description;
    }else if (![description.UIType isEqualToString:@"connect"]) {
        return [BbBasicParser scanObject:&scanner description:description];
    }else{
        return [BbBasicParser scanConnection:&scanner description:description];
    }
    
    return nil;
}

+ (BbObjectDescription *)scanObject:(NSScanner **)scan description:(BbDescription *)description
{
    BbObjectDescription *desc = [[BbObjectDescription alloc]init];
    desc.stackIndex = description.stackIndex;
    desc.stackInstruction = description.stackInstruction;
    desc.UIType = description.UIType;
    NSScanner *scanner = *scan;
    desc.UIPosition = [NSScanner scanUIPosition:&scanner];
    desc.UISize = [NSScanner scanUISize:&scanner];
    desc.BbObjectType = [NSScanner scanObjectType:&scanner];
    desc.BbObjectArgs = [NSScanner scanObjectArgs:&scanner];
    
    return desc;
}

+ (BbConnectionDescription *)scanConnection:(NSScanner **)scan description:(BbDescription *)description
{
    BbConnectionDescription *desc = [[BbConnectionDescription alloc]init];
    desc.stackIndex = description.stackIndex;
    desc.stackInstruction = description.stackInstruction;
    desc.UIType = description.UIType;
    NSScanner *scanner = *scan;
    NSArray *connectionArgs = [NSScanner scanConnectionArgs:&scanner];
    if (connectionArgs && connectionArgs.count == 4) {
        desc.senderObjectIndex = [connectionArgs[0]integerValue];
        desc.senderPortIndex = [connectionArgs[1]integerValue];
        desc.receiverObjectIndex = [connectionArgs[2]integerValue];
        desc.receiverPortIndex = [connectionArgs[3]integerValue];
        return desc;
    }
    
    return nil;
}

@end
