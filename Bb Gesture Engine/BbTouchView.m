//
//  BbTouchView.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbTouchView.h"

@interface BbTouchView ()

@property (nonatomic, strong)           NSMutableDictionary        *touchDurationDictionary;
@property (nonatomic, strong)           NSMutableDictionary        *touchMovementDictionary;

@end

@implementation BbTouchView

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

- (void)printTouchDictionary:(NSDictionary *)touchDictionary
{
    NSMutableString *printout = [[NSMutableString alloc]initWithString:@"\nTouch dictionary:"];
    for ( id aKey in touchDictionary.allKeys) {
        [printout appendFormat:@"\n%@ : %@",aKey,touchDictionary[aKey]];
    }
    
    [printout appendString:@"\n"];
    NSLog(@"%@",printout);
}

- (BOOL)dictionary:(NSDictionary *)dictionary containsTouch:(UITouch *)touch
{
    NSValue *touchValue = [NSValue valueWithNonretainedObject:touch];
    return [dictionary.allKeys containsObject:touchValue];
}

- (void)addTouch:(UITouch *)touch toDictionary:(NSMutableDictionary *)dictionary asKeyForValue:(id)value
{
    NSValue *touchValue = [NSValue valueWithNonretainedObject:touch];
    [dictionary setValue:value forKey:touchValue];
}

- (void)removeTouch:(UITouch *)touch fromDictionary:(NSMutableDictionary *)dictionary
{
    NSValue *touchValue = [NSValue valueWithNonretainedObject:touch];
    [dictionary removeObjectForKey:touchValue];
}

- (id)getValueForTouch:(UITouch *)touch fromDictionary:(NSDictionary *)dictionary
{
    NSValue *touchValue = [NSValue valueWithNonretainedObject:touch];
    return [dictionary valueForKey:touchValue];
}

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
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches.allObjects ) {
        if ( [self validateHaveTouch:touch] == YES ) {
            NSTimeInterval duration = [self getTouchDuration:touch];
            CGPoint movement = [self getTouchMovement:touch];
            NSLog(@"Updated touch vector:\t%@\t\t%@\t\t%@\t\t",@(duration),@(movement.x),@(movement.y));
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches.allObjects) {
        if ( [self validateHaveTouch:touch] == YES ) {
            NSTimeInterval duration = [self getTouchDuration:touch];
            CGPoint movement = [self getTouchMovement:touch];
            NSLog(@"Cancelled touch vector:\t%@\t\t%@\t\t%@\t\t",@(duration),@(movement.x),@(movement.y));
            [self removeTouch:touch fromDictionary:self.touchDurationDictionary];
            [self removeTouch:touch fromDictionary:self.touchMovementDictionary];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches.allObjects) {
        if ( [self validateHaveTouch:touch] == YES ) {
            NSTimeInterval duration = [self getTouchDuration:touch];
            CGPoint movement = [self getTouchMovement:touch];
            NSLog(@"Ending touch vector:\t%@\t\t%@\t\t%@\t\t",@(duration),@(movement.x),@(movement.y));
            [self removeTouch:touch fromDictionary:self.touchDurationDictionary];
            [self removeTouch:touch fromDictionary:self.touchMovementDictionary];
        }
    }
}

@end
