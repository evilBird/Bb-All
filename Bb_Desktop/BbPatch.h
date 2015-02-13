//
//  BbPatch.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+EntityParent.h"
#import "BbObject+Encoder.h"

@interface BbPatch : BbObject

- (void)connectObject:(NSUInteger)senderObjectIndex
                 port:(NSUInteger)senderPortIndex
             toObject:(NSUInteger)receiverObjectIndex
                 port:(NSUInteger)receiverPortIndex;

- (void)connectSender:(BbObject *)sender
               outlet:(BbOutlet *)outlet
           toReceiver:(BbObject *)receiver
                inlet:(BbInlet *)inlet;

- (void)connectOutlet:(BbOutlet *)outlet
              toInlet:(BbInlet *)inlet;

- (NSString *)textDescription;
- (NSArray *)UISize;

@end
