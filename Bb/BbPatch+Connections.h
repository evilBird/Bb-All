//
//  BbPatch+Connections.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/25/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"

@class BbConnectionDescription;
@interface BbPatch (Connections)

- (NSString *)connectOutlet:(BbOutlet *)outlet
                    toInlet:(BbInlet *)inlet;

- (BOOL)hasConnectionWithId:(NSString *)connectionId;
- (void)removeConnectionWithId:(NSString *)connectionId;

- (NSArray *)selectedConnections;

- (NSBezierPath *)pathForConnectionWithId:(NSString *)connectionId;
- (NSArray *)pathCoordinatesForConnectionWithId:(NSString *)connectionId;

- (void)addConnectionWithDescription:(BbConnectionDescription *)description;
- (void)addConnectionsWithDescriptions:(NSArray *)descriptions;

- (BOOL)refreshConnections;

- (BOOL)connection:(BbConnection *)connection
    containsObject:(BbObject *)object;

@end
