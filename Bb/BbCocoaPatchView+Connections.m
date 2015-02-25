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

- (void)patch:(BbPatch *)patch connectionsDidChange:(id)connections
{
    if (patch == self.patch && connections) {
        [self setNeedsDisplay:YES];
    }
}

- (void)connectOutletView:(BbCocoaPortView *)outletView
              toInletView:(BbCocoaPortView *)inletView
{
    if (!self.patch || !outletView || !inletView) {
        return;
    }
    
    BbOutlet *outlet = (BbOutlet *)outletView.entity;
    BbInlet *inlet = (BbInlet *)inletView.entity;
    NSString *connectionId = [self.patch connectOutlet:outlet toInlet:inlet];
    if (connectionId) {
        [self setNeedsDisplay:YES];
    }
}


- (BOOL)hitTestConnections:(NSPoint)point
{
    NSMutableArray *connections = self.patch.connections.allValues.mutableCopy;
    NSUInteger hitCount = 0;
    for (BbConnection *connection in connections) {
        if ([connection hitTest:point]) {
            
            if (connection.selected) {
                connection.selected = NO;
            }else{
                connection.selected = YES;
            }
            
            hitCount++;
        }
    }
    
    return (hitCount > 0);
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.patch.connections && self.patch.connections.allKeys.count) {
        for (NSString *connectionId in self.patch.connections.allKeys) {
            NSBezierPath *connectionPath = [self.patch pathForConnectionWithId:connectionId];
            [connectionPath stroke];
        }
    }

    if (!self.drawThisConnection || self.drawThisConnection.count != 4) {
        return;
    }
    
    NSMutableArray *a = self.drawThisConnection.mutableCopy;
    NSBezierPath *path = [NSBezierPath pathWithArray:a];
    [path stroke];
    
    self.drawThisConnection = nil;
    
}

@end
