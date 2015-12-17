//
//  BbiOSEntityView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#if TARGET_OS_IPHONE
// iOS code

#import <UIKit/UIKit.h>

@interface BbiOSEntityView : UIView

- (BbEntity *)entity;

- (CGRect)frame;
- (void)setFrame:(CGRect)frame;

- (CGPoint)center;

- (BOOL)selected;
- (void)setSelected:(BOOL)selected;

- (void)addSubview:(id<BbEntityView>)subview;
- (void)removeFromSuperview;

@end

#endif