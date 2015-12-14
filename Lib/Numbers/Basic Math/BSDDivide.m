//
//  BSDDivide.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDivide.h"

@implementation BSDDivide

- (instancetype)initWithDenominator:(NSNumber *)denominator
{
    return [super initWithArguments:denominator];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"/";
    NSNumber *initDenominator = (NSNumber *)arguments;
    if (initDenominator) {
        self.coldInlet.value = initDenominator;
    }else{
        self.coldInlet.value = @0.000001;
    }
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    return inlet;
}
- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initCold];
    inlet.name = @"cold";
    inlet.delegate = self;
    return inlet;
}

- (void)calculateOutput
{
    self.mainOutlet.value = @([self.hotInlet.value doubleValue] / [self.coldInlet.value doubleValue]);
}



@end
