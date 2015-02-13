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
#import "PureLayout.h"
#import "BbCocoaEntityViewDescription.h"

@interface BbCocoaEntityView : NSView <BbEntityView> {
    BOOL kSelected;
    CGPoint kCenter;
}

@property (nonatomic,weak)          BbEntity                        *entity;
@property (nonatomic,strong)        BbCocoaEntityViewDescription    *viewDescription;
@property (nonatomic)               NSPoint                         normalizedPosition;
@property (nonatomic,readonly)      NSColor                         *defaultColor;
@property (nonatomic,readonly)      NSColor                         *selectedColor;
@property (nonatomic,strong)        NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint              *centerYConstraint;

#pragma - designated initializer
- (instancetype)initWithEntity:(BbEntity *)entity
               viewDescription:(id)viewDescription
                      inParent:(id)parentView;


//Override to customize initialization
- (void)commonInitEntity:(BbEntity *)entity
         viewDescription:(id)viewDescription;

//Override to customize constraints
//Returns without installing constraints if parent view is nil
- (void)setupConstraintsInParentView:(id)parent;
- (void)refresh;
- (void)setEntity:(BbEntity *)entity;

#pragma BbEntityView Methods

- (CGPoint)center;
- (void)setCenter:(CGPoint)center;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)addSubview:(id<BbEntityView>)subview;

@end

//#endif