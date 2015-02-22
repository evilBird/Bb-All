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

static CGFloat kDefaultMinWidth = 100.0;

typedef void (^BbTextEditingDidEndHandler)(NSString *text);
typedef void (^BbTextEditingDidChangeHandler)(NSTextField *textField);
typedef void (^BbTextEditingDidBeginHandler)(NSTextField *textField);

typedef NS_ENUM(NSInteger, BbEntityViewSelectionState) {
    BbEntityViewSelectionState_DEFAULT,
    BbEntityViewSelectionState_SELECTED
};

@interface BbCocoaEntityView : NSView <BbEntityView> {
    //BOOL kSelected;
    CGPoint kCenter;
    CGFloat kMinWidth;
}

@property (nonatomic,weak)          BbEntity                        *entity;
@property (nonatomic,strong)        BbCocoaEntityViewDescription    *viewDescription;
@property (nonatomic)               NSPoint                         normalizedPosition;
@property (nonatomic,readonly)      NSColor                         *defaultColor;
@property (nonatomic,readonly)      NSColor                         *selectedColor;
@property (nonatomic,readonly)      NSColor                         *editingColor;
@property (nonatomic,strong)        NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint              *centerYConstraint;

@property (nonatomic,strong)        NSTextField                     *textField;
@property (nonatomic,strong)        BbTextEditingDidEndHandler      textEditingEndedHandler;
@property (nonatomic,strong)        BbTextEditingDidChangeHandler   textEditingChangedHandler;
@property (nonatomic,strong)        BbTextEditingDidBeginHandler    textEditingBeganHandler;

@property (nonatomic)               BOOL                            editing;
@property (nonatomic)               BOOL                            selected;

- (CGFloat)textExpansionFactor;
- (CGFloat)editingTextExpansionFactor;
- (CGFloat)defaultTextExpansionFactor;

#pragma - designated initializer

- (instancetype)initWithEntity:(id)entity
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

- (void)entityView:(id)sender didBeginEditingObject:(id)object;
- (void)entityView:(id)sender didEndEditingObject:(id)object;

- (void)entityViewDidBeginSelected:(id)sender;
- (void)entityViewDidEndSelected:(id)sender;

#pragma BbEntityView Methods

- (CGPoint)center;
- (void)setCenter:(CGPoint)center;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)addSubview:(id<BbEntityView>)subview;

@end

//#endif