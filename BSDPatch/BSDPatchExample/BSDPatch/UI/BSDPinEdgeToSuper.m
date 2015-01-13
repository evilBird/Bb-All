//
//  BSDConstraints.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDPinEdgeToSuper.h"
#import "PureLayout.h"

@implementation BSDPinEdgeToSuper

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pin2super";
}

- (void)calculateOutput
{
    NSNumber *sideVal = self.hotInlet.value;
    NSNumber *insetVal = self.coldInlet.value;
    ALEdge edge = [self edgeForNumber:sideVal];
    CGFloat inset = [insetVal floatValue];
    PinEdgeToSuperBlock block = ^(UIView *view){
        [view autoPinEdgeToSuperviewEdge:edge withInset:inset];
        [view layoutIfNeeded];
    };
    [self.mainOutlet output:block];
}

- (ALEdge)edgeForNumber:(NSNumber *)edgeNumber
{
    switch (edgeNumber.integerValue) {
        case 0:
            return ALEdgeTop;
            break;
        case 1:
            return ALEdgeRight;
            break;
        case 2:
            return ALEdgeBottom;
            break;
        case 3:
            return ALEdgeRight;
            break;
            
        default:
            return ALEdgeTop;
            break;
    }
}

@end
