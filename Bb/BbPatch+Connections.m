//
//  BbPatch+Connections.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch+Connections.h"
#import "BbConnection+Drawing.h"

@implementation BbPatch (Connections)

- (BOOL)hasConnectionWithId:(NSString *)connectionId
{
    if (!self.connections || !connectionId) {
        return NO;
    }
    
    NSSet *connectionIds = [NSSet setWithArray:self.connections.allKeys];
    
    return [connectionIds containsObject:connectionId];
}

- (NSString *)connectOutlet:(BbOutlet *)outlet toInlet:(BbInlet *)inlet
{
    BbConnection *connection = [BbConnection newWithOutlet:outlet
                                                     inlet:inlet];
    
    if (!self.connections) {
        self.connections = [NSMutableDictionary dictionary];
    }
    
    if ([self hasConnectionWithId:connection.connectionId]) {
        return nil;
    }
    
    [connection connect];
    
    [self.connections setObject:connection forKey:connection.connectionId];
    
    return connection.connectionId;
}

- (void)removeConnectionWithId:(NSString *)connectionId
{
    if (!self.connections || !connectionId || ![self hasConnectionWithId:connectionId]) {
        return;
    }
    
    BbConnection *connection = [self.connections valueForKey:connectionId];
    [self.connections removeObjectForKey:connectionId];
    [connection disconnect];
}

- (NSArray *)selectedConnections
{
    if (!self.connections) {
        return nil;
    }
    
    NSMutableArray *connections = self.connections.allValues.mutableCopy;
    NSPredicate *isSelected = [NSPredicate predicateWithFormat:@"%K == YES",@"selected"];
    NSArray *selected = [connections filteredArrayUsingPredicate:isSelected];
    
    return selected;
}

- (NSBezierPath *)pathForConnectionWithId:(NSString *)connectionId
{
    if (!self.connections || !connectionId || ![self hasConnectionWithId:connectionId]) {
        return nil;
    }
    
    BbConnection *connection = [self.connections valueForKey:connectionId];
    
    return [connection bezierPath];
}

- (NSArray *)pathCoordinatesForConnectionWithId:(NSString *)connectionId
{
    if (!self.connections || !connectionId || ![self hasConnectionWithId:connectionId]) {
        return nil;
    }
    
    BbConnection *connection = [self.connections valueForKey:connectionId];
    return [connection pathCoordinates];
}

- (void)addConnectionWithDescription:(BbConnectionDescription *)description
{
    NSMutableArray *allMyChildren = self.childObjects.mutableCopy;
    BbConnection *connection = [self connectionWithDescription:description childObjects:allMyChildren];
    
    if (!connection || [self hasConnectionWithId:connection.connectionId]) {
        return;
    }
    
    [connection connect];
    
    if (!self.connections) {
        self.connections = [NSMutableDictionary dictionary];
    }
    
    [self.connections setObject:connection forKey:connection.connectionId];
}

- (void)addConnectionsWithDescriptions:(NSArray *)descriptions
{
    for (BbConnectionDescription *description in descriptions) {
        [self addConnectionWithDescription:description];
    }
}

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description childObjects:(NSArray *)childObjects
{
    BbObject *sender,*receiver = nil;
    NSUInteger childCount = childObjects.count;
    if (description.senderObjectIndex >= childCount || description.receiverObjectIndex >= childCount) {
        return nil;
    }
    sender = [childObjects objectAtIndex:description.senderObjectIndex];
    receiver = [childObjects objectAtIndex:description.receiverObjectIndex];
    
    if (!sender || !receiver) {
        return nil;
    }
    
    BbOutlet *outlet = nil;
    NSUInteger outletCount = sender.outlets.count;
    if (description.senderPortIndex >= outletCount) {
        return nil;
    }
    outlet = sender.outlets[description.senderPortIndex];
    
    BbInlet *inlet = nil;
    NSUInteger inletCount = receiver.inlets.count;
    if (description.receiverPortIndex >= inletCount) {
        return nil;
    }
    
    inlet = receiver.inlets[description.receiverPortIndex];
    
    if (!sender || !receiver || !outlet || !inlet) {
        return nil;
    }
    
    BbConnection *result = [BbConnection connectOutlet:outlet toInlet:inlet];
    return result;
}

- (BOOL)refreshConnections
{
    if (!self.connections) {
        return NO;
    }
    
    NSMutableDictionary *toKeep = nil;
    NSMutableArray *toDestroy = nil;
    
    for (NSString *connectionId in self.connections.allKeys) {
        BbConnection *connection = [self.connections valueForKey:connectionId];
        if (!connection.isDirty) {
            if (!toKeep) {
                toKeep = [NSMutableDictionary dictionary];
            }
            
            [toKeep setObject:connection forKey:connection.connectionId];
        }else{
            if (!toDestroy) {
                toDestroy = [NSMutableArray array];
            }
            
            [toDestroy addObject:connection];
        }
    }
    
    self.connections = toKeep;
    BOOL viewShouldRefresh = (toDestroy.count > 0);
    [self destroyConnections:toDestroy];
    
    return viewShouldRefresh;
}

- (void)destroyConnections:(NSArray *)connections
{
    for (BbConnection *connection in connections) {
        [connection disconnect];
        [connection tearDown];
    }
    
    connections = nil;
}



@end
