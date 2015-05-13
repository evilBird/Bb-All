//
//  BSDStringOutlet.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDStringInlet.h"

@implementation BSDStringInlet

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
    return [value isKindOfClass:[NSString class]];
}

@end
