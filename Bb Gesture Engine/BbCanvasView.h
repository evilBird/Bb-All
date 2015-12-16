//
//  BbTouchView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbTouchView.h"

@protocol BbCanvasViewDelegate <NSObject>

- (void)canvasView:(id)sender evaluateTouch:(id)touch withObservedData:(id)data;
- (void)canvasView:(id)sender touchPhaseWillChangeToPhase:(NSInteger)touchPhase;
- (void)canvasView:(id)sender touchPhaseDidChangeToPhase:(NSInteger)touchPhase;

@end

@interface BbCanvasView : UIView <BbTouchView>

@property (nonatomic,weak)                              id<BbCanvasViewDelegate>        delegate;
@property (nonatomic, readonly)                         NSInteger                       touchPhase;
@property (nonatomic, getter=isIgnoringTouches)         BOOL                            ignoringTouches;

- (NSSet *) subviewClasses;

@end
