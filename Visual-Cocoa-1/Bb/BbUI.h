//
//  BbUI.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
// iOS code
#import <UIKit/UIKit.h>
#else
// OSX code
#import <AppKit/AppKit.h>
#endif

@class BbEntity,BbPatch;
@protocol BbEntityView <NSObject>
@optional

- (BbEntity *)entity;
- (void)setEntity:(BbEntity *)entity;

- (CGRect)frame;
- (void)setFrame:(CGRect)frame;

- (CGPoint)center;
- (void)setCenter:(CGPoint)center;

#if TARGET_OS_IPHONE
// iOS code
- (CGPoint)normalizedPosition;

- (CGRect)convertRect:(CGRect)rect fromView:(UIView *)view;
#else
// OSX code
- (NSPoint)normalizedPosition;

- (NSRect)convertRect:(NSRect)rect fromView:(NSView *)view;

#endif

- (BOOL)selected;
- (void)setSelected:(BOOL)selected;

- (void)refresh;

- (void)addSubview:(id<BbEntityView>)subview;
- (void)removeFromSuperview;

- (void)removeConnectionPathWithId:(NSString *)connectionId;
- (void)patch:(BbPatch *)patch connectionsDidChange:(id)connections;


@end

@protocol BbPlaceholderViewDelegate <NSObject>

- (void)placeholder:(id)sender enteredText:(NSString *)text;

@end
