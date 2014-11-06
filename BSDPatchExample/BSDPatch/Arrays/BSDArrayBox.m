//
//  BSDArrayBox.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayBox.h"

@implementation BSDArrayBox

- (void)setupWithArguments:(id)arguments
{
    self.name = @"array box";
    if (arguments && [arguments isKindOfClass:[NSArray class]]) {
        [self.coldInlet input:arguments];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if ([value isKindOfClass:[BSDBang class]]) {
        self.mainOutlet.value = self.coldInlet.value;
    }
}

- (void)reset
{
    self.coldInlet.value = NULL;
}

@end
