//
//  BSDDictionaryLength.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDictionaryLength.h"

@implementation BSDDictionaryLength

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"dict length";
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSDictionary *dict = self.hotInlet.value;
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        [self.mainOutlet output:@(dict.allKeys.count)];
    }
}

@end
