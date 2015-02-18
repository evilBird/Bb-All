//
//  BbCocoaPatchView+Touches.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"

typedef NS_ENUM(NSUInteger, BbViewType){
    BbViewType_Port,
    BbViewType_Object,
    BbViewType_Patch,
    BbViewType_None
};

@class BbCocoaEntityView;
@interface BbCocoaPatchView (Touches)

- (BbCocoaPatchGetConnectionArray)pathArrayWithConnection:(id)desc;

- (void)connectSender:(NSUInteger)senderIndex
               outlet:(NSUInteger)outletIndex
             receiver:(NSUInteger)receiverIndex
                inlet:(NSUInteger)inletIndex;
@end
