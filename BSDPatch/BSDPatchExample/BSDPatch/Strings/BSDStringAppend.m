//
//  BSDStringAppend.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/10/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDStringAppend.h"

@implementation BSDStringAppend

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"string append";
    if (!arguments) {
        return;
    }
    
    if ([arguments isKindOfClass:[NSString class]]) {
        [self.coldInlet input:arguments];
        return;
    }
    
    if ([arguments isKindOfClass:[NSArray class]]) {
        NSArray *args = arguments;
        if ([args.firstObject isKindOfClass:[NSString class]]) {
            [self.coldInlet input:args.firstObject];
            return;
        }
    }
}

- (BSDInlet *)makeLeftInlet
{
    BSDStringInlet *inlet = [[BSDStringInlet alloc]initHot];
    inlet.name = @"hot";
    inlet.delegate = self;
    return inlet;
}

- (BSDInlet *)makeRightInlet
{
    BSDStringInlet *inlet = [[BSDStringInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (void)calculateOutput
{
    NSString *hot = self.hotInlet.value;
    NSString *cold = self.coldInlet.value;
    if (!hot || !cold) {
        return;
    }
    
    NSString *output = [hot stringByAppendingString:cold];
    [self.mainOutlet output:output];
}

@end
