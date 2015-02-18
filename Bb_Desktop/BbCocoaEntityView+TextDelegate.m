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

@implementation BbCocoaEntityView (TextDelegate)

- (void)setupTextField
{
    self.textField = [[NSTextField alloc]initForAutoLayout];
    self.textField.backgroundColor = [NSColor clearColor];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.placeholderString = @"object";
    NSDictionary *textAttributes = [[self class]textAttributes];
    self.textField.font = [textAttributes valueForKey:NSFontAttributeName];
    self.textField.textColor = [textAttributes valueForKey:NSForegroundColorAttributeName];
    self.textField.delegate = self;
    self.textField.alignment = NSCenterTextAlignment;
    self.textField.backgroundColor = self.defaultColor;
    self.textField.bordered = NO;
    
    if (self.viewDescription.text) {
        self.textField.stringValue = self.viewDescription.text;
    }
    [(NSView *)self addSubview:self.textField];
    
    [self addObserver:self
           forKeyPath:@"selected"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)entityView:(id)sender didEndObservingText:(NSTextField *)text
{
    if (sender == self && text == self.textField) {
        [[text window]makeFirstResponder:nil];
        [text setEditable:NO];
    }else{
        
    }
}
- (void)entityView:(id)sender didBeginObservingText:(NSTextField *)text
{
    if (sender == self && text == self.textField) {
        [[text window]makeFirstResponder:text];
        [text setEditable:YES];
    }else{
        
    }
}

- (void)beginObservingText
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidBeginEditing:) name:NSTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
}

- (void)endObservingText
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSTextDidEndEditingNotification object:nil];
}

- (void)setupTextFieldConstraints
{
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint,
                                                                            kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint)];
    [self invalidateIntrinsicContentSize];
    [self layoutSubtreeIfNeeded];
    self.selected = NO;
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return NSSizeFromCGSize(size);
}
- (CGFloat)intrinsicContentHeight
{
    CGFloat contentHeight = kMinVerticalSpacerSize + 2.0f * kPortViewHeightConstraint;
    return contentHeight;
}

- (CGFloat)intrinsicTextWidth
{
    NSString *text = [NSString stringWithString:self.textField.stringValue];
    NSDictionary *textAttributes = [NSInvocation doClassMethod:NSStringFromClass([self class])
                                                  selectorName:@"textAttributes"
                                                          args:nil];
    CGFloat textWidthRaw = [text sizeWithAttributes:textAttributes].width;
    CGFloat textWidth = pow(textWidthRaw, 1.1);
    return textWidth;
}

- (CGFloat)intrinsicContentWidth
{
    if (!self.textField || !self.textField.stringValue || !self.textField.stringValue.length) {
        return kMinWidth;
    }
    
    CGFloat textWidth = [self intrinsicTextWidth];
    CGFloat textInsetsWidth = kPortViewWidthConstraint;
    CGFloat widthRequiredByText = textWidth + textInsetsWidth;
    if (widthRequiredByText >= kMinWidth) {
        return [NSView roundFloat:widthRequiredByText];
    }else{
        return kMinWidth;
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
        self.textEditingEndedHandler(weakself.textField.stringValue);
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        NSNumber *value = change[@"new"];
        BOOL isSelected = value.boolValue;
        if (isSelected) {
            [self beginObservingText];
            [self entityView:self didBeginObservingText:self.textField];
        }else{
            [self endObservingText];
            [self entityView:self didEndObservingText:self.textField];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selected"];
    [self endObservingText];
}

@end
