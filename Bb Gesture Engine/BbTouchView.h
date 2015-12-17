//
//  BbTouchView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#ifndef BbTouchView_h
#define BbTouchView_h

#import "BbGesture.h"

@protocol BbTouchView <NSObject>

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenTouchPhase:(NSUInteger)touchPhase;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenCanvasEditingState:(NSUInteger)editingState;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenGestureRepeatCount:(NSUInteger)repeatCount;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenOutletIsActiveInCanvas:(BOOL)outletIsActive;

@end

#endif /* BbTouchView_h */
