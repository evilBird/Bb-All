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
#import "BbNumberMatrix.h"
#import "NSInvocation+Bb.h"

static NSUInteger kNumTouchPhases = 4;
static NSString   *kCancelWhenRecognizedSelector = @"cancelsTouchesWhenRecognized";

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

- (NSArray *)candidateGestureClassesWithPossibles:(NSArray *)possibles
{
    NSArray *gestureClasses = [BbGesture allGestureClasses];
    NSAssert(gestureClasses.count==possibles.count, @"Number of gestures does not equal number of possibles");
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[BbMatrix arraySum:possibles].integerValue];
    NSEnumerator *gestureClassEnum = gestureClasses.objectEnumerator;
    for ( NSNumber *aPossible in possibles) {
        NSString *aGestureClass = [gestureClassEnum nextObject];
        if ( aPossible.integerValue > 0 ) {
            [temp addObject:aGestureClass];
        }
    }
    
    return [NSArray arrayWithArray:temp];
}

+ (NSArray *)trueVector
{
    return @[@(0),@(1)];
}

+ (NSArray *)falseVector
{
    return @[@(1),@(0)];
}

- (NSUInteger)evaluateGesture:(BbGestureType)gestureType repeatCount:(NSUInteger)repeatCount inView:(id<BbTouchView>)touchView
{
    NSArray *viewVector = [self touchRepeatVectorForView:touchView gestureType:gestureType];
    NSArray *stateVector = [self touchRepeatCountVector:repeatCount];
    BbNumberMatrix *matrix = [[BbNumberMatrix alloc]initWithRows:1 columns:stateVector.count];
    [matrix setValues:viewVector forElementsInRow:0];
    NSNumber *result = [matrix rowSumsByEvaluationInputArray:stateVector].firstObject;
    return result.unsignedIntegerValue;
}

- (NSArray *)touchRepeatVectorForView:(id<BbTouchView>)touchView gestureType:(BbGestureType)gestureType
{
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:2];
    for ( NSUInteger i = 1; i <= 2 ; i ++ ) {
        [vec addObject:@([touchView canRecognizeGesture:gestureType givenGestureRepeatCount:i])];
    }
    
    return vec;
}

- (NSArray *)touchRepeatCountVector:(NSUInteger)touchCount
{
    switch (touchCount) {
        case 1:
            return [BbTouchHandler falseVector];
            break;
        case 2:
            return [BbTouchHandler trueVector];
            break;
            
        default:
            return @[@(0),@(0)];
            break;
    }
}

- (NSUInteger)evaluateGesture:(BbGestureType)gestureType activeOutlet:(BOOL)activeOutlet inView:(id<BbTouchView>)touchView
{
    NSArray *viewVector = [self activeOutletVectorForView:touchView gestureType:gestureType];
    NSArray *stateVector = [self activeOutletVector:activeOutlet];
    BbNumberMatrix *matrix = [[BbNumberMatrix alloc]initWithRows:1 columns:stateVector.count];
    [matrix setValues:viewVector forElementsInRow:0];
    NSNumber *result = [matrix rowSumsByEvaluationInputArray:stateVector].firstObject;
    return result.unsignedIntegerValue;
}

- (NSArray *)activeOutletVectorForView:(id<BbTouchView>)touchView gestureType:(BbGestureType)gestureType
{
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:2];
    for ( NSUInteger i = 0; i < 2 ; i ++ ) {
        [vec addObject:@([touchView canRecognizeGesture:gestureType givenOutletIsActiveInCanvas:(BOOL)i])];
    }
    
    return vec;
}

- (NSArray *)activeOutletVector:(BOOL)activeOutlet
{
    if (activeOutlet) {
        return [BbTouchHandler trueVector];
    }
    
    return [BbTouchHandler falseVector];
}

- (NSUInteger)evaluateGesture:(BbGestureType)gestureType canvasEditingState:(BOOL)editing inView:(id<BbTouchView>)touchView
{
    NSArray *viewVector = [self editingStateVectorForView:touchView gestureType:gestureType];
    NSArray *stateVector = [self editingStateVector:editing];
    BbNumberMatrix *matrix = [[BbNumberMatrix alloc]initWithRows:1 columns:stateVector.count];
    [matrix setValues:viewVector forElementsInRow:0];
    NSNumber *result = [matrix rowSumsByEvaluationInputArray:stateVector].firstObject;
    return result.unsignedIntegerValue;
}

- (NSArray *)editingStateVectorForView:(id<BbTouchView>)touchView gestureType:(BbGestureType)gestureType
{
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:2];
    NSUInteger stateNO = [touchView canRecognizeGesture:gestureType givenCanvasEditingState:0];
    NSUInteger stateYES = [touchView canRecognizeGesture:gestureType givenCanvasEditingState:1];
    [vec addObject:@(stateNO)];
    [vec addObject:@(stateYES)];
    
    return vec;
}

- (NSArray *)editingStateVector:(BOOL)editing
{
    if (editing) {
        return [BbTouchHandler trueVector];
    }
    
    return [BbTouchHandler falseVector];
}

- (NSUInteger)evaluateGesture:(BbGestureType)gestureType withPhase:(NSUInteger)phase inView:(id<BbTouchView>)touchView
{
    NSArray *viewVector = [self touchPhaseVectorForView:touchView gestureType:gestureType];
    NSArray *phaseVector = [self touchPhaseVector:phase];
    BbNumberMatrix *matrix = [[BbNumberMatrix alloc]initWithRows:1 columns:phaseVector.count];
    [matrix setValues:viewVector forElementsInRow:0];
    NSNumber *result = [matrix rowSumsByEvaluationInputArray:phaseVector].firstObject;
    return result.unsignedIntegerValue;
}

- (NSArray *)touchPhaseVectorForView:(id<BbTouchView>)touchView gestureType:(BbGestureType)gestureType
{
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:kNumTouchPhases];
    for ( NSUInteger i = 0; i < kNumTouchPhases ; i ++ ) {
        [vec addObject:@([touchView canRecognizeGesture:gestureType givenTouchPhase:i])];
    }
    
    return vec;
}

- (NSArray *)touchPhaseVector:(NSUInteger)touchPhase
{
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:kNumTouchPhases];
    for (NSUInteger i = 0; i < kNumTouchPhases; i++) {
        NSNumber *e = ( i == touchPhase ) ? @(1) : @(0);
        [vec addObject:e];
    }
    
    return vec;
}

- (NSUInteger) evaluateCandidateGesture:(NSString *)gesture withTouch:(UITouch *)touch
{
    id <BbTouchView> touchView = (id<BbTouchView>)touch.view;
    NSNumber *gt = [NSInvocation doClassMethod:gesture selectorName:@"gestureType" args:nil];
    BbGestureType gestureType = (BbGestureType)gt.integerValue;
    if ( [self evaluateGesture:gestureType
                     withPhase:touch.phase
                        inView:touchView] == 0 ) {
        return 0;
    }
    
    if ( [self evaluateGesture:gestureType
            canvasEditingState:[self.datasource canvasIsEditing:self]
                        inView:touchView] == 0 ) {
        return 1;
    }
    
    if ( [self evaluateGesture:gestureType
                   repeatCount:touch.tapCount
                        inView:touchView] == 0 ) {
        return 2;
    }
    
    if ( [self evaluateGesture:gestureType
                  activeOutlet:[self.datasource canvasHasActiveOutlet:self]
                        inView:touchView] == 0 ) {
        return 3;
    }
    
    
    
    return 4;
}

- (void)evaluateTouch:(UITouch *)touch withPossibleGestures:(NSArray *)possibleGestures
{
    if ( [touch.view conformsToProtocol:@protocol(BbTouchView)] == NO ) {
        return;
    }
    NSArray *candidates = [self candidateGestureClassesWithPossibles:possibleGestures];
    //NSString *candidatesString = [candidates componentsJoinedByString:@", "];
    //NSLog(@"Will evaluate candidate gestures: %@",candidatesString);
    for ( NSString *aCandidate in candidates) {
        NSUInteger result = [self evaluateCandidateGesture:aCandidate withTouch:touch];
        if ( result == 4 ) {
            //NSLog(@"Candidate %@ = %@",aCandidate,@(result));
            NSLog(@"Recognized gesture %@",aCandidate);
            
            if ( [[NSInvocation doClassMethod:aCandidate
                                               selectorName:kCancelWhenRecognizedSelector
                                         args:nil]boolValue] == YES ){
                [self.canvasView setIgnoringTouches:YES];
                break;
            }
        }
    }
}

#pragma mark - BbCanvasViewDelegate

- (void)canvasView:(id)sender evaluateTouch:(id)touch withObservedData:(id)data
{
    NSArray *possibleGestures = [self.touchDataEvaluationMatrix rowProductsByEvaluatingInputArray:data];
    NSNumber *sum = [BbMatrix arraySum:possibleGestures];
    if ( sum.integerValue < 1 ) {
        return;
    }
    
    [self evaluateTouch:touch withPossibleGestures:possibleGestures];
}

- (void)canvasView:(id)sender touchPhaseWillChangeToPhase:(NSInteger)touchPhase
{
    BbCanvasView *view = sender;
    //NSLog(@"Touch phase will change from %@ to %@",@(view.touchPhase),@(touchPhase));
}

- (void)canvasView:(id)sender touchPhaseDidChangeToPhase:(NSInteger)touchPhase
{
    if ( touchPhase == 3 && [(BbCanvasView *)sender isIgnoringTouches] == YES ) {
        [(BbCanvasView *)sender setIgnoringTouches:NO];
    }
    //NSLog(@"Touch phase did change to %@",@(touchPhase));
}


@end
