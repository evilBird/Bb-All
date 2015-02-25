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
#import "BbConnection.h"
#import "BbProxyPort.h"

@interface BbPatch : BbObject;

- (void)addProxyPort:(id)port;

@property (nonatomic,strong)NSMutableSet *connectionIds;
@property (nonatomic,strong)NSMutableDictionary *connections;
@property (nonatomic,strong)NSMutableDictionary *myConnections;

- (void)addConnectionsWithDescriptions:(NSArray *)descriptions;

- (void)addConnectionWithDescription:(id)desc;

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


@interface BbPatch (ProxyPorts)

- (void)addInlet:(BbInlet *)inlet withProxy:(BbProxyInlet *)proxy;
- (void)addOutlet:(BbOutlet *)outlet withProxy:(BbProxyOutlet *)proxy;

@end

@interface BbCompiledPatch : BbPatch

@end

