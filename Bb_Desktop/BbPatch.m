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
    desc.senderObjectIndex = [sender indexInParent:sender.parent];
    desc.senderPortId = outlet.objectId;
    desc.senderPortIndex = [sender indexForPort:outlet];
    desc.receiverId = receiver.objectId;
    desc.receiverObjectIndex = [receiver indexInParent:receiver.parent];
    desc.receiverPortId = inlet.objectId;
    desc.receiverPortIndex = [receiver indexForPort:inlet];
    desc.ancestors = [self countAncestors]+1;
    
    return desc;
}

- (void)connectObject:(NSUInteger)senderObjectIndex
                 port:(NSUInteger)senderPortIndex
             toObject:(NSUInteger)receiverObjectIndex
                 port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    BbConnectionDescription *desc = [BbConnectionDescription new];
    desc.parentId = self.objectId;
    desc.senderId = sender.objectId;
    desc.senderObjectIndex = senderObjectIndex;
    desc.senderPortId = outlet.objectId;
    desc.senderPortIndex = senderPortIndex;
    desc.receiverId = receiver.objectId;
    desc.receiverObjectIndex = receiverObjectIndex;
    desc.receiverPortId = inlet.objectId;
    desc.receiverPortIndex = receiverPortIndex;
    desc.ancestors = [self countAncestors]+1;
    
    if (desc) {
        if (!self.connections) {
            self.connections = [[NSMutableDictionary alloc]init];
        }
        NSString *connectionId = [@([desc connectionId])toString];
        NSLog(@"connection id: %@\n%@",connectionId,[desc textDescription]);
        
        if ([self.connections.allKeys containsObject:connectionId]) {
            NSLog(@"error with connection: that connection already exists");
            return;
        }
        [self.connections setValue:desc forKey:connectionId];
        [self connectOutlet:outlet toInlet:inlet];
    }else{
        NSLog(@"error with connection");
    }
}

- (void)disconnectObject:(NSUInteger)senderObjectIndex
                    port:(NSUInteger)senderPortIndex
              fromObject:(NSUInteger)receiverObjectIndex
                    port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    BbConnectionDescription *desc = [BbConnectionDescription new];
    desc.parentId = self.objectId;
    desc.senderId = sender.objectId;
    desc.senderObjectIndex = senderObjectIndex;
    desc.senderPortId = outlet.objectId;
    desc.senderPortIndex = senderPortIndex;
    desc.receiverId = receiver.objectId;
    desc.receiverObjectIndex = receiverObjectIndex;
    desc.receiverPortId = inlet.objectId;
    desc.receiverPortIndex = receiverPortIndex;
    desc.ancestors = [self countAncestors]+1;
    
    NSString *connectionId = [@([desc connectionId])toString];
    
    if ([self.connections.allValues containsObject:connectionId]) {
        NSLog(@"will remove connection");

    }else{
        NSLog(@"connection not found");
    }
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
