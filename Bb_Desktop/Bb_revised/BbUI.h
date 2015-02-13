//
//  BbUI.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#if TARGET_OS_IPHONE
// iOS code
#import <UIKit/UIKit.h>
#else
// OSX code
#import <Cocoa/Cocoa.h>
#endif

@class BbEntity;
@protocol BbEntityView <NSObject>
@optional

- (BbEntity *)entity;
- (void)setEntity:(BbEntity *)entity;

- (CGRect)frame;
- (void)setFrame:(CGRect)frame;

- (CGPoint)center;
- (void)setCenter:(CGPoint)center;

- (BOOL)selected;
- (void)setSelected:(BOOL)selected;

- (void)refresh;

- (void)addSubview:(id<BbEntityView>)subview;
- (void)removeFromSuperview;

@end

@protocol BbPlaceholderViewDelegate <NSObject>

- (void)placeholder:(id)sender enteredText:(NSString *)text;

@end
