//
//  BbCocoaEntityView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#import "UIView+Bb.h"

#define VCView              UIView
#define VCColor             UIColor
#define VCPoint             CGPoint
#define VCTextField         UITextField
#define VCRect              CGRect
#define VCBezierPath        UIBezierPath
#define VCSize              CGSize
#define VCControl           UIControl
#define VCEvent             UIEvent
#define VCEdgeInsets        UIEdgeInsets
#define VCFont              UIFont
#define VCSlider            UISlider
#define VCEdgeInsetsZero    UIEdgeInsetsZero
#define VCEdgeInsets        UIEdgeInsets
#else

#import <AppKit/AppKit.h>
#import "NSView+Bb.h"

#define VCView              NSView
#define VCColor             NSColor
#define VCPoint             NSPoint
#define VCTextField         NSTextField
#define VCRect              NSRect
#define VCBezierPath        NSBezierPath
#define VCSize              NSSize
#define VCControl           NSControl
#define VCEvent             NSEvent
#define VCEdgeInsets        NSEdgeInsets
#define VCFont              NSFont
#define VCSlider            NSSlider
#define VCEdgeInsetsZero    NSEdgeInsetsZero
#define VCEdgeInsets        NSEdgeInsets
#endif

#import "BbUI.h"
#import "PureLayout.h"
#import "BbCocoaEntityViewDescription.h"

static CGFloat kDefaultMinWidth = 100.0;

typedef void (^BbTextEditingDidEndHandler)(NSString *text);
typedef void (^BbTextEditingDidChangeHandler)(VCTextField *textField);
typedef void (^BbTextEditingDidBeginHandler)(VCTextField *textField);

typedef NS_ENUM(NSInteger, BbEntityViewSelectionState) {
    BbEntityViewSelectionState_DEFAULT,
    BbEntityViewSelectionState_SELECTED
};

@interface BbCocoaEntityView : VCView <BbEntityView> {

    CGPoint kCenter;
    CGFloat kMinWidth;
}

@property (nonatomic,weak)          BbEntity                        *entity;
@property (nonatomic,strong)        BbCocoaEntityViewDescription    *viewDescription;

@property (nonatomic)               VCPoint                         normalizedPosition;
@property (nonatomic,readonly)      VCColor                         *defaultColor;
@property (nonatomic,readonly)      VCColor                         *selectedColor;
@property (nonatomic,readonly)      VCColor                         *editingColor;
@property (nonatomic,strong)        VCTextField                     *textField;

@property (nonatomic,strong)        NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint              *centerYConstraint;
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

- (VCPoint)center;
- (void)setCenter:(VCPoint)center;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)addSubview:(id<BbEntityView>)subview;

@end
