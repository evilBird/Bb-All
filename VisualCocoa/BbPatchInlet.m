//
//  BbPatchInlet.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatchInlet.h"

@implementation BbPatchInlet

- (void)setupWithArguments:(id)arguments
{
    self.name = @"";
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
}



@end
