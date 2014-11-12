//
//  BSDSplitDictionary.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSplitDictionary.h"

@implementation BSDSplitDictionary

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"split dict";
    self.keyOutlet = [[BSDOutlet alloc]init];
    self.keyOutlet.name = @"keys";
    [self addPort:self.keyOutlet];
    
    self.valueOutlet = [[BSDOutlet alloc]init];
    self.valueOutlet.name = @"values";
    [self addPort:self.valueOutlet];
    
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    NSDictionary *dict = self.hotInlet.value;
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        for (id aKey in dict.allKeys) {
            id value = dict[aKey];
            [self.keyOutlet output:aKey];
            [self.valueOutlet output:value];
        }
    }
}


@end
