//
//  BSDNumberOutlet.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/24/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumberOutlet.h"

@implementation BSDNumberOutlet

- (void)handleOutput:(id)output
{
    if ([self typeOK:output]) {
        
    }
    self.value = output;
}

- (BOOL)typeOK:(id)value
{
    return YES;
}

@end
