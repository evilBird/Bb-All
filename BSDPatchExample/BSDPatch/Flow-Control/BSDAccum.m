//
//  BSDAccum.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/14/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAccum.h"

@implementation BSDAccum

- (void)setupWithArguments:(NSArray *)arguments
{
    self.name = @"accum";
    self.coldInlet.value = @(0);
}

- (void)reset
{
    self.coldInlet.value = @(0);
}

- (void)calculateOutput
{
    self.coldInlet.value = @([self.hotInlet.value doubleValue] + [self.coldInlet.value doubleValue]);
    self.mainOutlet.value = self.coldInlet.value;
}


@end
