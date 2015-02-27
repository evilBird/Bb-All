//
//  BbCocoaPatchView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
#import "BbConnection+Drawing.h"
@class BbCocoaPortView,BbCocoaObjectView,BbObject,BbPatch;

@interface BbCocoaPatchView : BbCocoaEntityView <BbPlaceholderViewDelegate>
{
    CGPoint                kPreviousLoc;
    NSSize                 kInitOffset;
    NSUInteger             kClickCount;
}

// a connection is a vector of the form: @[x1,y1,x2,y2]
@property (nonatomic,strong)NSArray *drawThisConnection;

// underlying BbEntity
@property (nonatomic,readonly)BbPatch *patch;

@property (nonatomic,weak) id                   initialTouchView;
@property (nonatomic,weak) BbCocoaObjectView    *selectedObjectView;
@property (nonatomic,weak) BbCocoaPortView      *selectedPortViewSender;
@property (nonatomic,weak) BbCocoaPortView      *selectedPortViewReceiver;

- (BbObject *)addObjectWithText:(NSString *)text;
- (id)addPlaceholderAtPoint:(CGPoint)point;
- (void)addViewForObject:(BbObject *)object;
+ (instancetype)patchViewWithPatch:(BbPatch *)patch inView:(id)view;

@end
