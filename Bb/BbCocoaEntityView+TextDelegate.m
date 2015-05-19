//
//  BbCocoaEntityView+TextDelegate.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//


#import "BbCocoaEntityView+TextDelegate.h"
#import "BbCocoaPortView.h"
#import "BbCocoaObjectView.h"
#import "NSInvocation+Bb.h"
#import "BbCocoaObjectView+Autolayout.h"

#if TARGET_OS_IPHONE
#import "UIView+Bb.h"
#define VCTextDidBeginEditingNotification       UITextViewTextDidBeginEditingNotification
#define VCTextDidEndEditingNotification         UITextViewTextDidEndEditingNotification
#else
#import "NSView+Bb.h"
#define VCTextDidBeginEditingNotification       NSTextDidBeginEditingNotification
#define VCTextDidEndEditingNotification         NSTextDidEndEditingNotification
#endif

@implementation BbCocoaEntityView (TextDelegate)

- (void)setupTextField
{
    self.textField = [[VCTextField alloc]initForAutoLayout];
    self.textField.backgroundColor = [VCColor clearColor];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
#if TARGET_OS_IPHONE
    self.textField.placeholder = @"object";
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.borderStyle = UITextBorderStyleNone;
#else
    self.textField.placeholderString = @"object";
    self.textField.alignment = NSCenterTextAlignment;
    self.textField.bordered = NO;
#endif
    NSDictionary *textAttributes = [[self class]textAttributes];
    self.textField.font = [textAttributes valueForKey:NSFontAttributeName];
    self.textField.textColor = [textAttributes valueForKey:NSForegroundColorAttributeName];
    self.textField.delegate = self;
    if (self.viewDescription.text) {
#if TARGET_OS_IPHONE
        self.textField.text = self.viewDescription.text;
#else
        self.textField.stringValue = self.viewDescription.text;
#endif
    }
    
    [(VCView *)self addSubview:self.textField];
}

- (void)beginEditingText
{
    [self beginObservingText];
    #if TARGET_OS_IPHONE == 0
    [[self.textField window]makeFirstResponder:self.textField];
    [self.textField setEditable:YES];
    [self setNeedsDisplay:YES];
#endif

}

- (void)endEditingText
{
    [self endObservingText];
    #if TARGET_OS_IPHONE == 0
    [[self.textField window]makeFirstResponder:nil];
    [self.textField setEditable:NO];
    [self setNeedsDisplay:YES];
#endif

}

#if TARGET_OS_IPHONE == 0
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return self.editing;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return self.editing;
}

#endif

- (void)beginObservingText
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidBeginEditing:) name:VCTextDidBeginEditingNotification object:nil];
#if TARGET_OS_IPHONE

#else
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
#endif
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidEndEditing:) name:VCTextDidEndEditingNotification object:nil];
}

- (void)endObservingText
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VCTextDidBeginEditingNotification object:nil];
#if TARGET_OS_IPHONE
    
#else
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSTextDidChangeNotification object:nil];
#endif
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VCTextDidEndEditingNotification object:nil];
}

- (void)setupTextFieldConstraints
{
#if TARGET_OS_IPHONE
    VCEdgeInsets insets = UIEdgeInsetsMake(kPortViewHeightConstraint,
                                           kPortViewWidthConstraint,
                                           kPortViewHeightConstraint,
                                           kPortViewWidthConstraint);
#else
    VCEdgeInsets insets = NSEdgeInsetsMake(kPortViewHeightConstraint,
                                           kPortViewWidthConstraint,
                                           kPortViewHeightConstraint,
                                           kPortViewWidthConstraint);
#endif
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:insets];
    [self invalidateIntrinsicContentSize];
#if TARGET_OS_IPHONE
    
#else
    [self layoutSubtreeIfNeeded];
    
#endif
}

- (VCSize)intrinsicContentSize
{
    CGSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return size;
}
- (CGFloat)intrinsicContentHeight
{
    CGFloat contentHeight = kMinVerticalSpacerSize + 2.0f * kPortViewHeightConstraint;
    return contentHeight;
}

- (CGFloat)intrinsicTextWidth
{
 #if TARGET_OS_IPHONE
    NSString *text = [NSString stringWithString:self.textField.text];
#else
    NSString *text = [NSString stringWithString:self.textField.stringValue];
#endif   
    NSDictionary *textAttributes = [[self class]textAttributes];
    CGFloat textWidthRaw = [text sizeWithAttributes:textAttributes].width;
    CGFloat textWidth = pow(textWidthRaw, [self textExpansionFactor]);
    return textWidth;
}

- (CGFloat)intrinsicContentWidth
{
#if TARGET_OS_IPHONE
    NSString *text = self.textField.text;
#else
    NSString *text = self.textField.stringValue;
#endif
    if (!self.textField || !text || !text.length) {
        return kMinWidth;
    }
    
    CGFloat textWidth = [self intrinsicTextWidth];
    
    CGFloat textInsetsWidth = kPortViewWidthConstraint;
    CGFloat widthRequiredByText = textWidth + textInsetsWidth;
    if (widthRequiredByText >= kMinWidth) {
        return [VCView roundFloat:widthRequiredByText];
    }else{
        return kMinWidth + widthRequiredByText;
    }
}

#pragma mark - TextField editing notifications

- (void)textDidBeginEditing:(NSNotification *)notification
{
    __weak BbCocoaEntityView *weakself = self;
    if (self.textEditingBeganHandler != NULL) {
        self.textEditingBeganHandler(weakself.textField);
    }
}

- (void)textDidChange:(NSNotification *)notification
{
    __weak BbCocoaEntityView *weakself = self;
    if (self.textEditingChangedHandler != NULL) {
        self.textEditingChangedHandler(weakself.textField);
    }
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    __weak BbCocoaEntityView *weakself = self;
    if (self.textEditingEndedHandler != NULL) {
#if TARGET_OS_IPHONE
        self.textEditingEndedHandler(weakself.textField.text);
#else
        self.textEditingEndedHandler(weakself.textField.stringValue);
#endif
    }
}

- (void)dealloc
{
    [self endObservingText];
}

@end

