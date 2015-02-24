//
//  BbDictionary.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbDictionary.h"


@implementation BbDictionary

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"dict";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        id object = [inlets.lastObject getValue];
        id key = hotValue;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:object forKey:key];
        return dictionary;
    };
}

@end



@interface BbDictionaryAccumulate ()

@property (nonatomic,strong)BbInlet *accumInlet;
@property (nonatomic,strong)NSMutableDictionary *mutableDictionary;

@end

@implementation BbDictionaryAccumulate

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.accumInlet) {
        return [NSSet setWithObject:@(BbValueType_Dictionary)];
    }
    
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
    self.accumInlet = [BbInlet newHotInletNamed:@"accum"];
    [self addPort:self.accumInlet];
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
    self.name = @"dict accum";
}

- (void) hotInlet:(BbInlet *)inlet receivedBang:(BbBang *)bang
{
    if (inlet == self.accumInlet) {
        [self.mutableDictionary removeAllObjects];
    }
}

- (id) outputForOutlet:(BbOutlet *)outlet withChangeInHotInlet:(BbInlet *)hotInlet
{
    id output = nil;
    
    if (hotInlet == self.hotInlet) {
        if (self.mutableDictionary) {
            output = self.mutableDictionary.mutableCopy;
            return output;
        }else{
            return output;
        }
    }
    
    NSDictionary *accum = [self.accumInlet getValue];
    
    if (accum) {
        if (!self.mutableDictionary) {
            self.mutableDictionary = [NSMutableDictionary dictionary];
        }
        
        self.mutableDictionary[accum.allKeys.firstObject] = accum.allValues.firstObject;
    }
    
    return output;
}


@end
