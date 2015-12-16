//
//  BbBasicTouchHandler.h
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbCanvasView.h"

@protocol BbBasicTouchHandlerDelegate <NSObject>

- (void)touchHandler:(id)sender recognizedGestureWithTag:(NSString *)gestureTag;

- (void)touchHandler:(id)sender possibleGesturesWithTags:(NSArray *)gestureTags;

- (void)touchHandlerCancelTouchesInView:(id)sender;

@end

@interface BbBasicTouchHandler : NSObject <BbTouchViewDelegate>

@property (nonatomic,weak)          id<BbBasicTouchHandlerDelegate>             delegate;

- (instancetype)initWithTouchView:(BbCanvasView *)touchView delegate:(id<BbBasicTouchHandlerDelegate>)delegate;

@end
