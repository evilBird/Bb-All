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

@implementation BbCocoaEntityView (TextDelegate)

- (void)setupTextField
{
    self.textField = [[NSTextField alloc]initWithFrame:self.bounds];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.placeholderString = @"enter text";
    NSString *classString = NSStringFromClass([self class]);
    NSDictionary *textAttributes = [NSInvocation doClassMethod:classString
                                                  selectorName:@"textAttributes"
                                                          args:nil];//[BbCocoaEntityViewDescription textAttributes];
    self.textField.font = [textAttributes valueForKey:NSFontAttributeName];
    self.textField.textColor = [textAttributes valueForKey:NSForegroundColorAttributeName];
    self.textField.delegate = self;
    self.textField.alignment = NSCenterTextAlignment;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidBeginEditing:) name:NSTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:NSTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
    self.textField.backgroundColor = self.defaultColor;
    self.textField.bordered = NO;
    [(NSView *)self addSubview:self.textField];
}

- (void)setupTextFieldConstraints
{
    [self.textField autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsMake(kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint/2,
                                                                            kPortViewHeightConstraint,
                                                                            kPortViewWidthConstraint/2)];
    [self invalidateIntrinsicContentSize];
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
    if (self.textEditingBeganHandler != NULL) {
        self.textEditingBeganHandler(self.textField);
    }
}

- (void)textDidChange:(NSNotification *)notification
{
    [self invalidateIntrinsicContentSize];
    if (self.textEditingChangedHandler != NULL) {
        self.textEditingChangedHandler(self.textField);
    }
}

- (void)textDidEndEditing:(NSNotification *)notification
{
    [self.textField resignFirstResponder];
    if (self.textEditingEndedHandler != NULL) {
        self.textEditingEndedHandler(self.textField.stringValue);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
