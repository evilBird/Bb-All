//
//  BbCocoaPatchView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
@class BbCocoaPortView,BbCocoaObjectView,BbObject;

typedef NSArray* (^BbCocoaPatchGetConnectionArray)(void);

@interface BbCocoaPatchView : BbCocoaEntityView {
    
    CGPoint                kPreviousLoc;
    BbCocoaObjectView      *kSelectedObjectView;
    BbCocoaPortView        *kSelectedPortViewSender;
    BbCocoaPortView        *kSelectedPortViewReceiver;
    id                     kInitView;
}

// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSMutableSet *connections;
// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSArray *drawThisConnection;
//@property (nonatomic,strong)NSMutableSet *selectedPortViews;

- (BbObject *)addObjectAndViewWithText:(NSString *)text;

@end
