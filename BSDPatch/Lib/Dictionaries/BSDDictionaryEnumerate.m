//
//  BSDDictionaryEnumerate.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDictionaryEnumerate.h"

@implementation BSDDictionaryEnumerate

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"dict enum";
    NSDictionary *dict = arguments;
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        self.coldInlet.value = dict;
    }
    
    self.doneOutlet = [[BSDOutlet alloc]init];
    self.doneOutlet.name = @"done outlet";
    [self addPort:self.doneOutlet];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSMutableDictionary *dict = [self.coldInlet.value mutableCopy];
    NSMutableArray *array = [dict.allKeys mutableCopy];
    if (array.count > 0) {
        id key = array.firstObject;
        id value = dict[key];
        NSRange newRange;
        newRange.location = 1;
        newRange.length = array.count - 1;
        NSDictionary *output = @{key:value};
        [self.mainOutlet setValue:output];
        [dict removeObjectForKey:key];
        [self.coldInlet setValue:dict];
        if (newRange.length == 0) {
            [self.doneOutlet setValue:[BSDBang bang]];
        }
    }else{
        [self.doneOutlet setValue:[BSDBang bang]];
    }
}

@end
