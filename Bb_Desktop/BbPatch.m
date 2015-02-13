//
//  BbPatch.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"

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

- (void)connectObject:(NSUInteger)senderObjectIndex
                 port:(NSUInteger)senderPortIndex
             toObject:(NSUInteger)receiverObjectIndex
                 port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    [self connectSender:sender
                 outlet:sender.outlets[senderPortIndex]
             toReceiver:receiver
                  inlet:receiver.inlets[receiverPortIndex]];
}

- (void)connectSender:(BbObject *)sender
               outlet:(BbOutlet *)outlet
           toReceiver:(BbObject *)receiver
                inlet:(BbInlet *)inlet
{
    [outlet connectToInlet:inlet];
    
    BbOutlet *receiverOutlet = receiver.outlets.firstObject;
    receiverOutlet.outputBlock = ^(id value){
        NSLog(@"\n%@ value = %@",receiver.name,value);
    };
}

@end
