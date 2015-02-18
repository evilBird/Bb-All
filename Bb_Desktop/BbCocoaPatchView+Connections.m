//
//  BbCocoaPatchView+Connections.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView+Connections.h"
#import "BbPatch.h"
#import "BbCocoaPortView.h"

@implementation BbCocoaPatchView (Connections)

- (void)connectSender:(NSUInteger)senderIndex
               outlet:(NSUInteger)outletIndex
             receiver:(NSUInteger)receiverIndex
                inlet:(NSUInteger)inletIndex
{
    BbPatch *patch = (BbPatch *)self.entity;
    id desc = [patch connectObject:senderIndex
                              port:outletIndex
                          toObject:receiverIndex
                              port:inletIndex];
    
    NSDictionary *connection = [self connectionDictionaryWithDescription:desc];
    if (connection != nil) {
        if (!self.connections) {
            self.connections = [[NSMutableDictionary alloc]init];
        }
        
        [self.connections addEntriesFromDictionary:connection];
    }
}

- (void)connectPortView:(BbCocoaPortView *)sender toReceiver:(BbCocoaPortView *)receiver
{
    NSDictionary *senderInfo = [sender userInfo];
    NSDictionary *receiverInfo = [receiver userInfo];
    if (senderInfo && receiverInfo) {
        NSUInteger senderPortIndex = [senderInfo[@"port_index"]unsignedIntegerValue];
        NSUInteger senderParentIndex = [senderInfo[@"parent_index"]unsignedIntegerValue];
        NSUInteger receiverPortIndex = [receiverInfo[@"port_index"]unsignedIntegerValue];
        NSUInteger receiverParentIndex = [receiverInfo[@"parent_index"]unsignedIntegerValue];
        [self connectSender:senderParentIndex
                     outlet:senderPortIndex
                   receiver:receiverParentIndex
                      inlet:receiverPortIndex];
    }
}

- (NSDictionary *)connectionDictionaryWithDescription:(id)desc
{
    BbCocoaPatchGetConnectionArray connectionBlock;
    BbConnectionDescription *c = desc;
    connectionBlock = [self connectionBlockWithDescription:c];
    if (connectionBlock == NULL) {
        return nil;
    }
    
    NSString *connectionId = [NSString stringWithFormat:@"%@",@(c.connectionId)];
    return @{connectionId:connectionBlock};
}

- (BbCocoaPatchGetConnectionArray)connectionBlockWithDescription:(id)desc
{
    if (!desc) {
        return NULL;
    }
    
    BbConnectionDescription *c = desc;
    if (c.flag == BbConnectionDescriptionFlags_DELETE) {
        return NULL;
    }
    
    BbPatch *patch = (BbPatch *)self.entity;
    BbObject *sender = [patch childObjects][c.senderObjectIndex];
    BbOutlet *outlet = sender.outlets[c.senderPortIndex];
    BbObject *receiver = [patch childObjects][c.receiverObjectIndex];
    BbInlet *inlet = receiver.inlets[c.receiverPortIndex];
    BbCocoaPortView *outletView = (BbCocoaPortView *)outlet.view;
    BbCocoaPortView *inletView = (BbCocoaPortView *)inlet.view;
    
    if (!outletView || !inletView) {
        return NULL;
    }
    
    return [self connectionBlockSender:outletView receiver:inletView];
    
}
- (BbCocoaPatchGetConnectionArray)connectionBlockSender:(BbCocoaPortView *)sender receiver:(BbCocoaPortView *)receiver
{
    __weak BbCocoaPatchView *weakself = self;
    BbCocoaPatchGetConnectionArray connectionBlock = ^ NSArray *{
        
        CGRect senderRect = [weakself convertRect:sender.bounds fromView:sender];
        CGRect receiverRect = [weakself convertRect:receiver.bounds fromView:receiver];
        NSArray *senderPoint = @[@(CGRectGetMidX(senderRect)),@(CGRectGetMidY(senderRect))];
        NSArray *receiverPoint = @[@(CGRectGetMidX(receiverRect)),@(CGRectGetMidY(receiverRect))];
        NSArray *result = nil;
        if (senderPoint && receiverPoint) {
            NSMutableArray *temp = [NSMutableArray array];
            [temp addObjectsFromArray:senderPoint];
            [temp addObjectsFromArray:receiverPoint];
            result = [NSArray arrayWithArray:temp];
        }
        return result;
    };
    
    return connectionBlock;
}

- (NSBezierPath *)connectionPathFromArray:(NSArray *)array
{
    if (!array || array.count != 4) {
        return nil;
    }
    
    CGFloat x1,y1,x2,y2;
    x1 = [array[0] doubleValue];
    y1 = [array[1] doubleValue];
    x2 = [array[2] doubleValue];
    y2 = [array[3] doubleValue];
    
    CGPoint point = CGPointMake(x1, y1);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    [path lineToPoint:point];
    
    [path setLineWidth:4];
    [[NSColor blackColor]setStroke];
    
    return path;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSMutableArray *connections = self.connections.allValues.mutableCopy;
    if (connections) {
        for (BbCocoaPatchGetConnectionArray block in connections) {
            NSBezierPath *connectionPath = [self connectionPathFromArray:block()];
            [connectionPath stroke];
        }
    }
    
    if (!self.drawThisConnection || self.drawThisConnection.count != 4) {
        return;
    }
    
    NSMutableArray *a = self.drawThisConnection.mutableCopy;
    NSBezierPath *path = [self connectionPathFromArray:a];
    [path stroke];
    
    self.drawThisConnection = nil;
    
}

@end
