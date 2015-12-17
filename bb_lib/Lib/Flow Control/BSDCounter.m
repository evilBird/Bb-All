//
//  BSDCounter.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/14/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCounter.h"

@interface BSDCounter ()

@property (nonatomic)NSNumber *stepSize;
@property (nonatomic)NSNumber *initialValue;

@end

@implementation BSDCounter

- (instancetype)initWithStepSize:(NSNumber *)stepSize
                    initialValue:(NSNumber *)initialValue
{
    return [super initWithArguments:@{@"stepSize":stepSize,
                                      @"initialValue":initialValue}];
}

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(NSDictionary *)arguments
{
    self.name = @"counter";
    self.coldInlet.value = @(0);
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]initCold];
    inlet.name = @"cold";
    inlet.delegate = self;
    return inlet;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }else{
        [self reset];
    }
}

- (void)reset
{
    self.coldInlet.value = @(0);
}

- (void)calculateOutput
{
    double cold = [self.coldInlet.value doubleValue];
    double result = cold+1;
    self.coldInlet.value = @(result);
    self.mainOutlet.value = @(result);
}

@end
