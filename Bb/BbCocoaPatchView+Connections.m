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

- (void)removeConnectionPathWithId:(NSString *)connectionId
{
    if ([self.connections.allKeys containsObject:connectionId]) {
        [self.connections removeObjectForKey:connectionId];
    }else{
        NSLog(@"I don't have a connection with id %@",connectionId);
    }
}

- (void)patch:(BbPatch *)patch connectionsDidChange:(id)connections
{
    
    if (patch == self.patch && connections) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        NSArray *connects = connections;
        for (BbConnectionDescription *desc in connects) {
            NSDictionary *dict = [self connectionDictionaryWithDescription:desc];
            if (dict) {
                [temp addEntriesFromDictionary:dict];
            }
        }
        
        self.connections = nil;
        self.connections = temp;
        [self setNeedsDisplay:YES];
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
    BbConnectionCalculatePathBlock connectionBlock;
    BbConnectionDescription *c = desc;
    connectionBlock = [self connectionBlockWithDescription:c];
    if (connectionBlock == NULL) {
        return nil;
    }
    
    NSString *connectionId = [NSString stringWithFormat:@"%@",@(c.connectionId)];
    return @{connectionId:connectionBlock};
}

- (BbConnectionCalculatePathBlock)connectionBlockWithDescription:(id)desc
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
- (BbConnectionCalculatePathBlock)connectionBlockSender:(BbCocoaPortView *)sender receiver:(BbCocoaPortView *)receiver
{
    __weak BbCocoaPatchView *weakself = self;
    BbConnectionCalculatePathBlock connectionBlock = ^ NSArray *{
        
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

- (void)hitTestConnections:(NSDictionary *)connections withPoint:(NSPoint)point
{
    BOOL shouldRefresh = NO;
    for (NSString *connectionId in connections.allKeys) {
        BbConnectionCalculatePathBlock block = [connections valueForKey:connectionId];
        NSArray *array = block();
        BOOL hit = [self line:array intersectsPoint:point];
        if (hit) {
            shouldRefresh = YES;
            if (!self.selectedConnections) {
                self.selectedConnections = [[NSMutableSet alloc]init];
            }
            
            if (![self.selectedConnections containsObject:connectionId]) {
                [self.selectedConnections addObject:connectionId];
            }else{
                [self.selectedConnections removeObject:connectionId];
                if (self.selectedConnections.count == 0) {
                    self.selectedConnections = nil;
                }
            }
        }
    }
    
    if (shouldRefresh) {
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)line:(NSArray *)array intersectsPoint:(NSPoint)point
{
    CGFloat x1,y1,x2,y2,x3,y3,dx,dx1,dy,m,b;
    if (!array || array.count == 0) {
        return NO;
    }
    
    x1 = [array[0] doubleValue];
    y1 = [array[1] doubleValue];
    x2 = [array[2] doubleValue];
    y2 = [array[3] doubleValue];
    x3 = point.x;
    y3 = point.y;
    
    if (x2 > x1) {
        if (!(x2 >= x3) || !(x3>= x1)) {
            return NO;
        }
        
        dx = x2 - x1;
        dy = y2 - y1;
        b = y1;
        dx1 = x3 - x1;
        
    }else{
        if (!(x1 >= x3) || !(x3>= x2)) {
            return NO;
        }
        
        dx = x1 - x2;
        dy = y1 - y2;
        b = y2;
        dx1 = x3 - x2;
    }
    
    if (y2 > y1) {
        if (!(y2>=y3) || !(y3>=y1)) {
            return NO;
        }
    }else{
        if (!(y1>=y3) || !(y3>=y2)) {
            return NO;
        }
    }
    
    m = dy/dx;
    CGFloat yhat = m * dx1 + b;
    CGFloat error = fabs(yhat - y3);
    NSLog(@"error = %.2f",error);
    
    if (error < 8) {
        return YES;
    }
    
    return NO;
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

- (NSBezierPath *)connectionPathFromArray:(NSArray *)array selected:(BOOL)selected
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
    if (!selected) {
        [[NSColor blackColor]setStroke];
    }else{
        [[NSColor colorWithWhite:0.5 alpha:1]setStroke];
    }
    
    return path;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.connections && self.connections.allKeys.count) {
        for (NSString *connectionId in self.connections.allKeys) {
            BbConnectionCalculatePathBlock block = [self.connections valueForKey:connectionId];
            BOOL selected = [self.selectedConnections containsObject:connectionId];
            NSBezierPath *connectionPath = [self connectionPathFromArray:block() selected:selected];
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
