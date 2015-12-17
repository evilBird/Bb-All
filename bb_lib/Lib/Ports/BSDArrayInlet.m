//
//  NSArrayInlet.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayInlet.h"

@implementation BSDArrayInlet

- (void)handleInput:(id)input
{
    if ([self typeOk:input]) {
        self.connectionStatus = 1;
        self.value = input;
    }else{
        self.connectionStatus = 2;
    }
}

- (BOOL)typeOk:(id)value
{
    return [value isKindOfClass:[NSArray class]];
}

@end
