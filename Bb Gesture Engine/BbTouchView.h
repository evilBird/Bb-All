//
//  BbTouchView.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#ifndef BbTouchView_h
#define BbTouchView_h

typedef NS_ENUM(NSUInteger, BbGestureType) {
    BbGestureType_Tap           =   0,
    BbGestureType_LongPress     =   1,
    BbGestureType_SwipeLeft     =   2,
    BbGestureType_SwipeRight    =   3,
    BbGestureType_SwipeUp       =   4,
    BbGestureType_SwipeDown     =   5,
    BbGestureType_Pan           =   6
};

@protocol BbTouchView <NSObject>

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenTouchPhase:(NSUInteger)touchPhase;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenCanvasEditingState:(NSUInteger)editingState;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenGestureRepeatCount:(NSUInteger)repeatCount;
- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenOutletIsActiveInCanvas:(BOOL)outletIsActive;

@end

#endif /* BbTouchView_h */
