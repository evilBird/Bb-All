//
//  BbTouchView.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbTouchView.h"

@interface UITouch (TouchKey)

- (NSString *)touchKey;

@end

@implementation UITouch (TouchKey)

- (NSString *)touchKey
{
    NSUInteger hash = [self hash];
    return [NSString stringWithFormat:@"%@",@(hash)];
}

@end

@interface BbTouchView ()

@property (nonatomic, strong)                                       NSMutableDictionary        *touchDurationDictionary;
@property (nonatomic, strong)                                       NSMutableDictionary        *touchMovementDictionary;
@property (nonatomic, getter=isIgnoringTouches)                     BOOL                        ignoringTouches;

@end

@implementation BbTouchView

#pragma mark - Public methods

- (void)startIgnoringTouches
{
    self.ignoringTouches = YES;
}

- (void)stopIgnoringTouches
{
    self.ignoringTouches = NO;
}

- (NSSet *)subviewClasses
{
    NSArray *subviews = self.subviews;
    if ( nil == subviews || subviews.count == 0 ) {
        return nil;
    }
    NSMutableSet *subviewClasses = nil;
    for ( id subview in subviews) {
        NSString *className = NSStringFromClass([subview class]);
        if ( nil == subviewClasses ) {
            subviewClasses = [NSMutableSet setWithObject:className];
        }else{
            [subviewClasses addObject:className];
        }
    }
    
    return [NSSet setWithSet:subviewClasses];
}

#pragma mark - Private Methods

#pragma mark - Touch handlers

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if ( nil == self.touchDurationDictionary ){
        self.touchDurationDictionary = [NSMutableDictionary dictionary];
    }
    
    if ( nil == self.touchMovementDictionary ) {
        self.touchMovementDictionary = [NSMutableDictionary dictionary];
    }
    
    for (UITouch *touch in touches.allObjects) {
        
        if ( [self validateTouchIsNew:touch] == YES ) {
            
            [self addTouch:touch toDictionary:self.touchDurationDictionary asKeyForValue:@(touch.timestamp)];
            [self addTouch:touch toDictionary:self.touchMovementDictionary asKeyForValue:[NSValue valueWithCGPoint:[touch locationInView:self]]];
            
            if ( self.isIgnoringTouches == NO ) {
                
                [self.delegate touchView:self
                           evaluateTouch:touch
                        withObservedData:[self dataArrayWithTouch:touch]
                 ];

            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    for (UITouch *touch in touches.allObjects ) {
        if ( [self validateHaveTouch:touch] == YES ) {
            if ( self.isIgnoringTouches == NO ) {
                [self.delegate touchView:self
                           evaluateTouch:touch
                        withObservedData:[self dataArrayWithTouch:touch]
                 ];
                //NSLog(@"Updated touch vector:\t%.2f\t%.2f\t%.2f\t",duration,movement.x,movement.y);
                
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    for (UITouch *touch in touches.allObjects) {
        
        if ( [self validateHaveTouch:touch] == YES ) {

            if ( self.isIgnoringTouches == NO ) {
                
                [self.delegate touchView:self
                           evaluateTouch:touch
                        withObservedData:[self dataArrayWithTouch:touch]
                 ];
                //NSLog(@"Cancelled touch vector:\t%.2f\t%.2f\t%.2f\t",duration,movement.x,movement.y);
            }
            [self removeTouch:touch fromDictionary:self.touchDurationDictionary];
            [self removeTouch:touch fromDictionary:self.touchMovementDictionary];
        }
    }
    
    [self stopIgnoringTouches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches.allObjects) {
        if ( [self validateHaveTouch:touch] == YES ) {

            if ( self.isIgnoringTouches == NO ) {
                
                [self.delegate touchView:self
                           evaluateTouch:touch
                        withObservedData:[self dataArrayWithTouch:touch]
                 ];
            }
            //NSLog(@"Ending touch vector:\t%.2f\t%.2f\t%.2f\t",duration,movement.x,movement.y);

            [self removeTouch:touch fromDictionary:self.touchDurationDictionary];
            [self removeTouch:touch fromDictionary:self.touchMovementDictionary];
        }
    }
    [self stopIgnoringTouches];
}


#pragma mark - Data collection & Collation

- (NSTimeInterval)getTouchDuration:(UITouch *)touch
{
    NSNumber *startTimeStamp = [self getValueForTouch:touch fromDictionary:self.touchDurationDictionary];
    NSTimeInterval startTime = startTimeStamp.doubleValue;
    NSTimeInterval currentTime = touch.timestamp;
    return (currentTime - startTime);
}

- (CGPoint)getTouchMovement:(UITouch *)touch
{
    NSValue *startPointValue = [self getValueForTouch:touch fromDictionary:self.touchMovementDictionary];
    CGPoint startPoint = startPointValue.CGPointValue;
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint movement;
    movement.x = (currentPoint.x - startPoint.x);
    movement.y = (currentPoint.y - startPoint.y);
    return movement;
}

- (CGPoint)getNormalizedTouchMovement:(UITouch *)touch
{
    NSValue *startPointValue = [self getValueForTouch:touch fromDictionary:self.touchMovementDictionary];
    CGPoint startPoint = startPointValue.CGPointValue;
    CGPoint currentPoint = [touch locationInView:self];
    CGSize mySize = self.bounds.size;
    CGPoint movement = [BbTouchView unitVectorWithPoint:currentPoint center:startPoint size:mySize];
    return movement;
}

+ (CGPoint)unitVectorWithPoint:(CGPoint)point center:(CGPoint)center size:(CGSize)size
{
    CGPoint uv;
    CGFloat dx = (point.x-center.x)/size.width*2.0;
    CGFloat dy = (point.y-center.y)/size.height*2.0;
    uv.x = dx;
    uv.y = dy;
    return uv;
}

- (NSArray *)dataArrayWithTouch:(UITouch *)touch
{
    NSTimeInterval duration = [self getTouchDuration:touch];
    CGPoint movement = [self getNormalizedTouchMovement:touch];
    return @[@(duration),@(movement.x),@(movement.y)];
}

- (void)printTouchDictionary:(NSDictionary *)touchDictionary
{
    NSMutableString *printout = [[NSMutableString alloc]initWithString:@"\nTouch dictionary:"];
    for ( id aKey in touchDictionary.allKeys) {
        [printout appendFormat:@"\n%@ : %@",aKey,touchDictionary[aKey]];
    }
    
    [printout appendString:@"\n"];
    NSLog(@"%@",printout);
}

#pragma mark - Helpers

- (BOOL)dictionary:(NSDictionary *)dictionary containsTouch:(UITouch *)touch
{
    return [dictionary.allKeys containsObject:[touch touchKey]];
}

- (void)addTouch:(UITouch *)touch toDictionary:(NSMutableDictionary *)dictionary asKeyForValue:(id)value
{
    [dictionary setValue:value forKey:[touch touchKey]];
}

- (void)removeTouch:(UITouch *)touch fromDictionary:(NSMutableDictionary *)dictionary
{
    [dictionary removeObjectForKey:[touch touchKey]];
}

- (id)getValueForTouch:(UITouch *)touch fromDictionary:(NSDictionary *)dictionary
{
    return [dictionary valueForKey:[touch touchKey]];
}

#pragma mark - Validation

- (BOOL)validateTouchIsNew:(UITouch *)touch
{
    BOOL haveTouchDuration = [self dictionary:self.touchDurationDictionary containsTouch:touch];
    BOOL haveTouchMovement = [self dictionary:self.touchMovementDictionary containsTouch:touch];
    return ( !haveTouchDuration && !haveTouchMovement );
}

- (BOOL)validateHaveTouch:(UITouch *)touch
{
    BOOL haveTouchDuration = [self dictionary:self.touchDurationDictionary containsTouch:touch];
    BOOL haveTouchMovement = [self dictionary:self.touchMovementDictionary containsTouch:touch];
    NSAssert(haveTouchDuration, @"Touch is not present in duration dictionary");
    NSAssert(haveTouchMovement, @"Touch is not present in movement dictionary");
    return YES;
}


@end
