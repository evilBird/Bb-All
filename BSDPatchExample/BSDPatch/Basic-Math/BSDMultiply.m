//
//  BSDMultiply.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMultiply.h"

@implementation BSDMultiply

- (void)setupWithArguments:(id)arguments
{
    self.name = @"multiply";
}

- (id)calculateOutputValue
{
    double result = [self.hotInlet.value doubleValue] * [self.coldInlet.value doubleValue];
    return @(result);
}

@end
