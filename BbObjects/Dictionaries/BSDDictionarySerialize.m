//
//  BSDDictionaryDrip.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDictionarySerialize.h"

@implementation BSDDictionarySerialize

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [super initWithArguments:dictionary];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"dictionary serialize";
    NSDictionary *dictionary = arguments;
    if (dictionary) {
        self.coldInlet.value = dictionary;
    }
    
    self.doneOutlet = [[BSDOutlet alloc]init];
    self.doneOutlet.name = @"done";
    [self addPort:self.doneOutlet];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        NSMutableDictionary *dictionary = [self.coldInlet.value mutableCopy];
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            for (id aKey in dictionary.allKeys) {
                self.mainOutlet.value = @{aKey: dictionary[aKey]};
            }
        }
        
        self.doneOutlet.value = [BSDBang bang];
    }
}

@end
