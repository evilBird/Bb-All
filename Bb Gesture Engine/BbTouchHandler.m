//
//  BbTouchHandler.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/16/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbTouchHandler.h"
#import "BbTouchView.h"
#import "BbGesture.h"

@interface BbTouchHandler () <BbTouchViewDelegate>

@property (nonatomic,weak)              BbTouchView             *touchView;
@property (nonatomic,strong)            BbBlockMatrix           *touchDataEvaluationMatrix;

@end

@implementation BbTouchHandler

- (instancetype)initWithTouchView:(BbTouchView *)touchView
                         delegate:(id<BbTouchHandlerDelegate>)delegate
                        datasouce:(id<BbTouchHandlerDataSource>)datasource
{
    self = [super init];
    if ( self ) {
        _touchView = touchView;
        _delegate = delegate;
        _datasource = datasource;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.touchDataEvaluationMatrix = [BbGesture gesturePossibleEvaluationMatrix];
    self.touchView.delegate = self;
}

#pragma mark - BbTouchViewDelegate

- (void)touchView:(id)sender evaluateTouch:(id)touch withObservedData:(id)data
{
    NSArray *possibleGestures = [self.touchDataEvaluationMatrix rowProductsByEvaluatingInputArray:data];
    NSLog(@"possible gestures: %@",possibleGestures);
}


@end
