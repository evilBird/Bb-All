//
//  BbTouchView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BbTouchViewDelegate <NSObject>

- (void)touch:(UITouch *)touch changedInView:(id)sender data:(NSArray *)data;
- (void)touch:(UITouch *)touch cancelledInView:(id)sender data:(NSArray *)data;
- (void)touch:(UITouch *)touch endedInView:(id)sender data:(NSArray *)data;
- (void)touch:(UITouch *)touch inView:(id)sender data:(NSArray *)data;

@end

@interface BbTouchView : UIView

@property (nonatomic,weak)  id<BbTouchViewDelegate> delegate;

- (void)gestureWasRecognized;

@end
