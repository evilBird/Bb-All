//
//  BSDBezierPath.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBezierPath.h"
#import "BSDArrayInlet.h"
#import "BSDNumberInlet.h"

@implementation BSDBezierPath

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"bezier path";
    self.coldInlet.value = @(0);
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    inlet.objectId = self.objectId;
    return inlet;
}
- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDNumberInlet alloc]initHot];
    inlet.name = @"cold";
    inlet.delegate = self;
    inlet.objectId = self.objectId;
    return inlet;
}

- (void)calculateOutput
{
    NSArray *hot = self.hotInlet.value;
    if (!hot) {
        return;
    }
    NSMutableArray *points = hot.mutableCopy;
    NSNumber *isClosed = self.coldInlet.value;
    UIBezierPath *output = [self pathFromArray:points closed:isClosed];
    [self.mainOutlet output:output.copy];
}

- (UIBezierPath *)pathFromArray:(NSArray *)array closed:(NSNumber *)closed
{
    UIBezierPath *result = nil;
    
    for (id element in array) {
        if ([element isKindOfClass:[NSValue class]]) {
            NSValue *e = element;
            CGPoint point = e.CGPointValue;
            if (result == nil) {
                result = [UIBezierPath bezierPath];
                [result moveToPoint:point];
            }else{
                [result addLineToPoint:point];
            }
        }
    }
    
    if (closed.integerValue > 0 && result) {
        [result closePath];
    }
    
    return result;
}

@end
