//
//  BSDAny2String.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDAny2String.h"

@implementation BSDAny2String

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"any2string";
    
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    
    NSString *output = [NSString stringWithFormat:@"%@",hot];
    [self.mainOutlet output:output];
}

@end
