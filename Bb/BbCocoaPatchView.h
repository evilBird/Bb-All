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
    NSSize                 kInitOffset;
    NSUInteger             kClickCount;
}

// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSMutableDictionary *connections;
// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSArray *drawThisConnection;

@property (nonatomic,strong)NSMutableSet *selectedConnections;
// underlying BbEntity
@property (nonatomic,readonly)BbPatch *patch;

@property (nonatomic,weak) id                   initialTouchView;
@property (nonatomic,weak) BbCocoaObjectView    *selectedObjectView;
@property (nonatomic,weak) BbCocoaPortView      *selectedPortViewSender;
@property (nonatomic,weak) BbCocoaPortView      *selectedPortViewReceiver;

- (BbObject *)addObjectWithText:(NSString *)text;
- (id)addPlaceholderAtPoint:(CGPoint)point;
+ (instancetype)patchViewWithPatch:(BbPatch *)patch inView:(id)view;

@end
