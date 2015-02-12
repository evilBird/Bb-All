//
//  BbCocoaEntityView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

//#ifndef TARGET_OS_IPHONE


#import <Cocoa/Cocoa.h>
#import "NSView+Bb.h"
#import "BbUI.h"

@interface BbCocoaEntityView : NSView <BbEntityView> {
    BOOL kSelected;
}

@property (nonatomic,weak)          BbEntity                        *entity;
@property (nonatomic,weak)          BbCocoaEntityView               *parentView;
@property (nonatomic,readonly)      NSColor                         *defaultColor;
@property (nonatomic,readonly)      NSColor                         *selectedColor;

- (void)setupConstraints;
- (void)commonInit;
- (void)setParentView:(BbCocoaEntityView *)parentView;

#pragma BbEntityView Methods

- (BbEntity *)entity;
- (void)refreshEntityView;
- (CGRect)frame;
- (void)setFrame:(CGRect)frame;
- (CGPoint)center;
- (void)setCenter:(CGPoint)center;
- (void)setCenter:(CGPoint)center inView:(id<BbEntityView>)view;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)addSubview:(id<BbEntityView>)subview;
- (void)removeFromSuperview;

@end

//#endif