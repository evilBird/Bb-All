//
//  BSDFont.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDFont.h"

@implementation BSDFont

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"font";
    
    self.fontNameInlet = [[BSDStringInlet alloc]initCold];
    self.fontNameInlet.name = @"font name";
    [self addPort:self.fontNameInlet];
    
    self.fontSizeInlet = [[BSDNumberInlet alloc]initCold];
    self.fontSizeInlet.name = @"font size";
    [self addPort:self.fontSizeInlet];
    
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]] && args.count == 2) {
        self.fontNameInlet.value = args[0];
        self.fontSizeInlet = args[1];
    }else{
        self.fontNameInlet.value = @"HelveticaNeue";
        self.fontSizeInlet.value = @(14);
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSString *fontName = self.fontNameInlet.value;
    NSNumber *fontSize = self.fontSizeInlet.value;
    
    if (!fontName || !fontSize) {
        return;
    }
    
    UIFont *output = [UIFont fontWithName:fontName size:fontSize.floatValue];
    [self.mainOutlet output:output];
}

@end
