//
//  BbCocoaPatchView+Connections.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/17/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"
@class BbCocoaPortView;
@interface BbCocoaPatchView (Connections)

- (BbCocoaPatchGetConnectionArray)connectionBlockWithDescription:(id)desc;

- (BbCocoaPatchGetConnectionArray)connectionBlockSender:(BbCocoaPortView *)sender
                                               receiver:(BbCocoaPortView *)receiver;

- (void)connectPortView:(BbCocoaPortView *)sender
             toReceiver:(BbCocoaPortView *)receiver;

- (void)connectSender:(NSUInteger)senderIndex
               outlet:(NSUInteger)outletIndex
             receiver:(NSUInteger)receiverIndex
                inlet:(NSUInteger)inletIndex;

- (NSBezierPath *)connectionPathFromArray:(NSArray *)array;

- (void)removeConnectionPathWithId:(NSString *)connectionId;

@end
