//
//  BSDPower.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDExponent.h"

@implementation BSDExponent

- (instancetype)initWithExponent:(NSNumber *)exponent
{
    return [super initWithArguments:exponent];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"^";
    NSNumber *initExponent = arguments;
    if (initExponent) {
        self.coldInlet.value = initExponent;
    }else{
        self.coldInlet.value = @0;
    }
}

- (void)calculateOutput
{
    self.mainOutlet.value = @(pow([self.hotInlet.value doubleValue], [self.coldInlet.value doubleValue]));
}


@end
