//
//  BbBasicTouchHandler.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbBasicTouchHandler.h"
#import "BbBlockMatrix+Helpers.h"

static NSString *kTapTag = @"tap";
static NSString *kLongPressTag = @"long press";
static NSString *kSwipeLeftTag = @"swipe left";
static NSString *kSwipeRightTag = @"swipe right";
static NSString *kSwipeUpTag = @"swipe up";
static NSString *kSwipeDownTag = @"swipe down";
static NSString *kPanTag = @"pan";

@interface BbBasicTouchHandler ()

@property (nonatomic,strong)        NSArray                 *gestureTags;
@property (nonatomic,strong)        BbBlockMatrix           *evaluationMatrix;

@end

@implementation BbBasicTouchHandler

- (void)testExpression
{

}

- (void)commonInit
{
    self.gestureTags = @[kTapTag,kLongPressTag,kSwipeLeftTag,kSwipeRightTag,kSwipeUpTag,kSwipeDownTag,kPanTag];
    self.evaluationMatrix = [[BbBlockMatrix alloc]initWithRows:self.gestureTags.count columns:4];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorWithMaxValue:0.2],
                                           [BbBlockMatrix evaluatorWithMaxValue:0.01],
                                           [BbBlockMatrix evaluatorWithMaxValue:0.01],
                                           [BbBlockMatrix evaluatorWithExactValue:3]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kTapTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorWithMinValue:0.5],
                                           [BbBlockMatrix evaluatorWithMaxValue:0.01],
                                           [BbBlockMatrix evaluatorWithMaxValue:0.01],
                                           [BbBlockMatrix evaluatorWithExactValue:3]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kLongPressTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorTrue],
                                           [BbBlockMatrix evaluatorWithMaxValue:-0.01],
                                           [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
                                           [BbBlockMatrix evaluatorWithExactValue:1]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kSwipeLeftTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorTrue],
                                           [BbBlockMatrix evaluatorWithMinValue:0.01],
                                           [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
                                           [BbBlockMatrix evaluatorWithExactValue:1]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kSwipeRightTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorTrue],
                                           [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
                                           [BbBlockMatrix evaluatorWithMaxValue:-0.01],
                                           [BbBlockMatrix evaluatorWithExactValue:1]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kSwipeUpTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorTrue],
                                           [BbBlockMatrix evaluatorWithMaxAbsValue:0.02],
                                           [BbBlockMatrix evaluatorWithMinValue:0.01],
                                           [BbBlockMatrix evaluatorWithExactValue:1]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kSwipeDownTag]];
    
    [self.evaluationMatrix setEvaluators:@[[BbBlockMatrix evaluatorWithMinValue:0.1],
                                           [BbBlockMatrix evaluatorWithMinAbsValue:0.01],
                                           [BbBlockMatrix evaluatorWithMinAbsValue:0.01],
                                           [BbBlockMatrix evaluatorWithExactValue:1]
                                           ]
                        forElementsInRow:[self.gestureTags indexOfObject:kPanTag]];
    
}

- (instancetype)initWithTouchView:(BbTouchView *)touchView delegate:(id<BbBasicTouchHandlerDelegate>)delegate
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        touchView.delegate = self;
        [self commonInit];
    }
    
    return self;
}

- (NSArray *)tagsForPossibleGesturesWithResults:(NSArray *)results
{
    NSUInteger i = 0;
    NSMutableArray *tags = nil;
    for (NSNumber *element in results) {
        if ( element.doubleValue > 0 ) {
            NSString *tag = self.gestureTags[i];
            if ( nil == tags ) {
                tags = [NSMutableArray arrayWithObject:tag];
            }else{
                [tags addObject:tag];
            }
        }
        
        i++;
    }
    
    return tags;
}

#pragma mark - BbTouchViewDelegate

- (void)touch:(UITouch *)touch inView:(id)sender data:(NSArray *)data
{
    NSArray *eval = [self.evaluationMatrix rowProductsByEvaluatingInputArray:data];
    NSArray *tags = [self tagsForPossibleGesturesWithResults:eval];
    [self handleGestureTags:tags];
}

- (void)handleGestureTags:(NSArray *)tags
{
    switch (tags.count) {
        case 0:
            break;
        case 1:
            [self.delegate touchHandler:self recognizedGestureWithTag:tags.firstObject];
            break;
            
        default:
            [self.delegate touchHandler:self possibleGesturesWithTags:tags];
            break;
    }
}


@end
