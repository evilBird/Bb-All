//
//  BbCocoaEntityView+TextDelegate.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

@interface BbCocoaEntityView (TextDelegate) <NSTextDelegate,NSTextFieldDelegate>

- (void)setupTextField;
- (void)setupTextFieldConstraints;
- (NSSize)intrinsicContentSize;
- (CGFloat)intrinsicContentHeight;
- (CGFloat)intrinsicTextWidth;
- (CGFloat)intrinsicContentWidth;

- (void)textDidBeginEditing:(NSNotification *)notification;
- (void)textDidChange:(NSNotification *)notification;
- (void)textDidEndEditing:(NSNotification *)notification;

@end
