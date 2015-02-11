//
//  BbCocoaPortView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPortView.h"
#import "NSView+Bb.h"

@implementation BbCocoaPortView

#pragma mark - Public Methods

- (void)commonInit
{
    [super commonInit];
}

- (void)setupConstraints
{
    
}

#pragma mark - Overrides
- (NSColor *)defaultColor
{
    return [NSColor whiteColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.7 alpha:1];
}

@end
