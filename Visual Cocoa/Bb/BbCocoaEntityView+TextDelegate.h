//
//  BbCocoaEntityView+TextDelegate.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//
#import "BbCocoaEntityView.h"
#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE == 0
#import <AppKit/AppKit.h>
@interface BbCocoaEntityView (TextDelegate) <NSTextDelegate,NSTextFieldDelegate>
#else
#import <UIKit/UIKit.h>
@interface BbCocoaEntityView (TextDelegate) <UITextFieldDelegate, UITextViewDelegate>

#endif

- (void)setupTextField;
- (void)setupTextFieldConstraints;
- (VCSize)intrinsicContentSize;
- (CGFloat)intrinsicContentHeight;
- (CGFloat)intrinsicTextWidth;
- (CGFloat)intrinsicContentWidth;

- (void)beginEditingText;
- (void)endEditingText;

- (void)beginObservingText;
- (void)endObservingText;
#if TARGET_OS_IPHONE == 0
- (BOOL)control:(VCControl *)control textShouldBeginEditing:(NSText *)fieldEditor;
- (BOOL)control:(VCControl *)control textShouldEndEditing:(NSText *)fieldEditor;
#endif

- (void)textDidBeginEditing:(NSNotification *)notification;
- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification *)notification;

@end
