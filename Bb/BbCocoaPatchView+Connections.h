//
//  BbCocoaPatchView+Connections.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"
#import "BbPatch+Connections.h"

@class BbCocoaPortView;
@interface BbCocoaPatchView (Connections)

- (void)connectOutletView:(BbCocoaPortView *)outletView
             toInletView:(BbCocoaPortView *)inletView;

- (BOOL)hitTestConnections:(NSPoint)point;
- (void)patch:(BbPatch *)patch connectionsDidChange:(id)connections;

@end
