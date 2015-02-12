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
//@property (nonatomic,weak)          BbCocoaEntityView               *parentView;
@property (nonatomic,readonly)      NSColor                         *defaultColor;
@property (nonatomic,readonly)      NSColor                         *selectedColor;


//Pragma designated initializer
- (instancetype)initWithDescription:(id)viewDescription
                           inParent:(id)parentView;

- (instancetype)initWithDescription:(id)viewDescription;

//When a subclass is initialized, common init is called
- (void)commonInit;
- (void)commonInitDescription:(id)viewDescription;

//Then the parent view is set, which adds the subclass to the view heirarchy
//- (void)setParentView:(BbCocoaEntityView *)parentView;
//Then once the sublcass is part of the view heirarchy, setupConstraints is called
- (void)setupConstraints;
- (void)setupConstraintsParent:(id)parent;
//Finally once the subclass is in the view heirarchy and its constraints are set, refreshEntityView calls setNeedsLayout followed by setNeedsDisplay
- (void)refreshEntityView;

#pragma BbEntityView Methods

- (BbEntity *)entity;
- (CGRect)frame;
- (CGPoint)center;
- (void)setCenter:(CGPoint)center;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)addSubview:(id<BbEntityView>)subview;

@end

//#endif