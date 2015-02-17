//
//  BbCocoaPatchView+Touches.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"
@class BbCocoaEntityView;
@interface BbCocoaPatchView (Touches)

- (void)moveEntityView:(BbCocoaEntityView *)entityView toPoint:(NSPoint)point;
- (NSPoint)normalizePoint:(NSPoint)point;
- (NSPoint)scaleNormalizedPoint:(NSPoint)point;
- (BbCocoaPatchGetConnectionArray)pathArrayWithConnection:(id)desc;
- (void)connectSender:(NSUInteger)senderIndex
               outlet:(NSUInteger)outletIndex
             receiver:(NSUInteger)receiverIndex
                inlet:(NSUInteger)inletIndex;
@end
