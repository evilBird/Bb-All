//
//  BbPatch.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+EntityParent.h"
#import "BbObject+Encoder.h"
#import "BbParsers.h"

@interface BbPatch : BbObject

@property (nonatomic,strong)NSMutableSet *connectionIds;
@property (nonatomic,strong)NSMutableDictionary *connections;

- (id)connectObject:(NSUInteger)senderObjectIndex
               port:(NSUInteger)senderPortIndex
           toObject:(NSUInteger)receiverObjectIndex
               port:(NSUInteger)receiverPortIndex;

- (id)disconnectObject:(NSUInteger)senderObjectIndex
                    port:(NSUInteger)senderPortIndex
              fromObject:(NSUInteger)receiverObjectIndex
                    port:(NSUInteger)receiverPortIndex;

- (BOOL)hasConnectionWithId:(NSString *)connectionId;

- (void)deleteConnectionWithId:(NSString *)connectionId;

- (void)connectOutlet:(BbOutlet *)outlet
              toInlet:(BbInlet *)inlet;

- (NSString *)textDescription;

- (NSArray *)UISize;

@end
