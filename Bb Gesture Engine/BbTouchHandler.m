//
//  BbTouchHandler.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbTouchHandler.h"
#import "BbCanvasView.h"
#import "BbGesture.h"

@interface BbTouchHandler () <BbCanvasViewDelegate>

@property (nonatomic,weak)              BbCanvasView            *canvasView;
@property (nonatomic,strong)            BbBlockMatrix           *touchDataEvaluationMatrix;

@end

@implementation BbTouchHandler

- (instancetype)initWithCanvasView:(BbCanvasView *)canvasView
                         delegate:(id<BbTouchHandlerDelegate>)delegate
                        datasouce:(id<BbTouchHandlerDataSource>)datasource
{
    self = [super init];
    if ( self ) {
        _canvasView = canvasView;
        _delegate = delegate;
        _datasource = datasource;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.touchDataEvaluationMatrix = [BbGesture gesturePossibleEvaluationMatrix];
    self.canvasView.delegate = self;
}

#pragma mark - BbCanvasViewDelegate

- (void)canvasView:(id)sender evaluateTouch:(id)touch withObservedData:(id)data
{
    NSArray *possibleGestures = [self.touchDataEvaluationMatrix rowProductsByEvaluatingInputArray:data];
    NSLog(@"possible gestures: %@",possibleGestures);
}

- (void)canvasView:(id)sender touchPhaseWillChangeToPhase:(NSInteger)touchPhase
{
    BbCanvasView *view = sender;
    NSLog(@"Touch phase will change from %@ to %@",@(view.touchPhase),@(touchPhase));
}

- (void)canvasView:(id)sender touchPhaseDidChangeToPhase:(NSInteger)touchPhase
{
    NSLog(@"Touch phase did change to %@",@(touchPhase));
}


@end
