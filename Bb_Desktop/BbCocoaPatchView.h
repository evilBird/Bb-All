//
//  BbCocoaPatchView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
@class BbCocoaPortView,BbCocoaObjectView,BbObject,BbPatch;

typedef NSArray* (^BbCocoaPatchGetConnectionArray)(void);

@interface BbCocoaPatchView : BbCocoaEntityView <BbPlaceholderViewDelegate>
{
    CGPoint                kPreviousLoc;
    NSSize                  kInitOffset;
    BbCocoaObjectView      *kSelectedObjectView;
    BbCocoaPortView        *kSelectedPortViewSender;
    BbCocoaPortView        *kSelectedPortViewReceiver;
    id                     kInitView;
}

// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSMutableSet *connections;
// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSArray *drawThisConnection;

@property (nonatomic,readonly)BbPatch *patch;

- (BbObject *)addObjectWithText:(NSString *)text;
- (id)addPlaceholderAtPoint:(CGPoint)point;

@end
