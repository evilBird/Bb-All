//
//  BSDSortDescriptor.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/5/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSortDescriptor.h"

@implementation BSDSortDescriptor

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"sort by";
    
    NSString *keyPath = arguments;
    if (keyPath && [keyPath isKindOfClass:[NSString class]]) {
        self.coldInlet.value = keyPath;
    }
}

- (void)calculateOutput
{
    NSNumber *hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[NSNumber class]]) {
        return;
    }
    NSString *cold = self.coldInlet.value;
    
    if (!cold || ![cold isKindOfClass:[NSString class]]) {
        return;
    }
    
    BOOL ascending = hot.boolValue;
    NSString *keypath = [NSString stringWithString:cold];
    
    NSSortDescriptor *output = [NSSortDescriptor sortDescriptorWithKey:keypath ascending:ascending];
    [self.mainOutlet output:output];
}

@end
