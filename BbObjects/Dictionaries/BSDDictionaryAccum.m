//
//  BSDDictionaryAccum.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDictionaryAccum.h"

@interface BSDDictionaryAccum ()

@property (nonatomic,strong)NSMutableDictionary *dictionary;

@end

@implementation BSDDictionaryAccum

- (void)setupWithArguments:(id)arguments
{
    self.name = @"dict accum";
    
    self.dictionaryInlet = [[BSDInlet alloc]initHot];
    self.dictionaryInlet.name = @"dict";
    self.dictionaryInlet.delegate = self;
    [self addPort:self.dictionaryInlet];
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self.mainOutlet output:self.dictionary.mutableCopy];
    }else if (inlet == self.dictionaryInlet){
        [self.dictionary removeAllObjects];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.dictionaryInlet) {
        if (value == nil) {
            return;
        }
        NSDictionary *val = value;
        NSMutableDictionary *new = [val mutableCopy];
        [self updateDictionaryWithDictionary:new];
    }
}

- (void)updateDictionaryWithDictionary:(NSDictionary *)dictionary
{
    for (id aKey in dictionary.allKeys) {
        if (!self.dictionary) {
            self.dictionary = [NSMutableDictionary dictionary];
        }
        self.dictionary[aKey] = dictionary[aKey];
    }
}

@end
