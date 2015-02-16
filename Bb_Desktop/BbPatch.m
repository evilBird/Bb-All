//
//  BbPatch.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"
#import "NSMutableString+Bb.h"
#import "BbCocoaEntityView.h"

@implementation BbPatch

#pragma child objects

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"patch";
    if (!arguments) {
        return;
    }
}

- (BbConnectionDescription *)descConnectionSender:(BbObject *)sender
                                           outlet:(BbOutlet *)outlet
                                       toReceiver:(BbObject *)receiver
                                            inlet:(BbInlet *)inlet
{
    BbConnectionDescription *desc = [BbConnectionDescription new];
    desc.parentId = self.objectId;
    desc.senderId = sender.objectId;
    desc.senderObjectIndex = [self indexOfChild:sender];
    desc.senderPortId = outlet.objectId;
    desc.senderPortIndex = [sender indexOfPort:outlet];
    desc.receiverId = receiver.objectId;
    desc.receiverObjectIndex = [self indexOfChild:receiver];
    desc.receiverPortId = inlet.objectId;
    desc.receiverPortIndex = [receiver indexOfPort:inlet];
    desc.ancestors = [self countAncestors]+1;
    desc.flag = BbConnectionDescriptionFlags_OK;
    
    return desc;
}

- (id)connectObject:(NSUInteger)senderObjectIndex
               port:(NSUInteger)senderPortIndex
           toObject:(NSUInteger)receiverObjectIndex
               port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    BbConnectionDescription *desc = nil;
    desc = [self descConnectionSender:sender
                               outlet:outlet
                           toReceiver:receiver
                                inlet:inlet];
    if (desc) {
        if (!self.connections) {
            self.connections = [[NSMutableDictionary alloc]init];
        }
        NSString *connectionId = [@([desc connectionId])toString];
        if ([self.connections.allKeys containsObject:connectionId]) {
            return nil;
        }
        [self.connections setValue:desc forKey:connectionId];
        [self connectOutlet:outlet toInlet:inlet];
    }
    
    return desc;
}

- (id)disconnectObject:(NSUInteger)senderObjectIndex
                    port:(NSUInteger)senderPortIndex
              fromObject:(NSUInteger)receiverObjectIndex
                    port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    BbConnectionDescription *desc = nil;
    desc = [self descConnectionSender:sender
                               outlet:outlet
                           toReceiver:receiver
                                inlet:inlet];
    
    NSString *connectionId = [@([desc connectionId])toString];
    
    if ([self.connections.allValues containsObject:connectionId]) {
        [self.connections removeObjectForKey:connectionId];
        desc.flag = BbConnectionDescriptionFlags_DELETE;
        return desc;
    }
    return nil;
}

- (void)connectOutlet:(BbOutlet *)outlet
              toInlet:(BbInlet *)inlet
{
    [outlet connectToInlet:inlet];
}

- (NSString *)textDescription
{
    NSMutableString *desc = [NSMutableString newDescription];
    [desc appendObject:[super textDescription]];
    if (self.connections){
        for (NSString *connectionId in self.connections.allKeys) {
            BbConnectionDescription *connection = [self.connections valueForKey:connectionId];
            if (connection.flag == BbConnectionDescriptionFlags_OK) {
                [desc appendObject:[connection textDescription]];
            }
        }
    }
    
    [desc appendThenSpace:@"#C"];
    [desc appendThenSpace:@"restore"];
    [desc appendThenSpace:self.creationArguments];
    [desc semiColon];
    [desc lineBreak];
    
    return desc;
}

- (NSArray *)UISize
{
    if (!self.view) {
        return nil;
    }
    
    CGSize size;
    size = [(NSView *)self.view intrinsicContentSize];
    return @[@(size.width),@(size.height)];
}

+ (NSString *)UIType
{
    return @"canvas";
}

+ (NSString *)stackInstruction
{
    return @"#N";
}

@end
