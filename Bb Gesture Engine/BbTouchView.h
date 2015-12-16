//
//  BbTouchView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BbTouchViewDelegate <NSObject>

- (void)touchView:(id)sender evaluateTouch:(id)touch withObservedData:(id)data;

@end

@interface BbTouchView : UIView

@property (nonatomic,weak)  id<BbTouchViewDelegate> delegate;

- (void) startIgnoringTouches;

- (void) stopIgnoringTouches;

- (NSSet *) subviewClasses;

@end
