//
//  BSDArrayMake.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayPack.h"
#import "BSDCreate.h"

@interface BSDArrayPack ()

@property (nonatomic,strong)NSArray *pairedInletNames;
@property (nonatomic,strong)NSArray *orderedInlets;

@end

@implementation BSDArrayPack

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pack";
    NSNumber *packCount = arguments;
    if (packCount && [packCount isKindOfClass:[NSNumber class]]) {
        for (NSUInteger idx = 0; idx < packCount.integerValue; idx ++) {
            BSDInlet *inlet = nil;
            if (idx == 0) {
                inlet = [[BSDInlet alloc]initHot];
                inlet.delegate = self;
            }
            
            inlet.name = [NSString stringWithFormat:@"%@-Inlet-%@",self.objectId,@(idx)];
            [self addPort:inlet];
        }
    }
}

- (BSDInlet *)makeLeftInlet
{
    return nil;
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.inlets.firstObject) {
        [self calculateOutput];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.inlets.firstObject) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    if (!self.inlets) {
        return;
    }
    
    NSMutableArray *output = nil;
    for (BSDInlet *inlet in self.inlets) {
        id value = inlet.value;
        if (value == nil) {
            return;
        }
        
        if (!output) {
            output = [NSMutableArray array];
        }
        
        [output addObject:value];
    }
    
    if (output) {
        [self.mainOutlet output:output.mutableCopy];
    }
}

- (void)test
{
    BSDValue *box1 = [BSDCreate valueBoxCold:@(1)];
    BSDValue *box2 = [BSDCreate valueBoxCold:@(100)];
    BSDValue *box3 = [BSDCreate valueBoxCold:@(1000)];
    [self setupWithArguments:@[@"not an outlet",box1.mainOutlet,box2.mainOutlet,box3.mainOutlet]];
    self.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        NSLog(@"composed array: %@",outlet.value);
    };
    
    NSLog(@"will bang box 2");
    [box2.hotInlet input:[BSDBang bang]];
    NSLog(@"will bang box 1");
    [box1.hotInlet input:[BSDBang bang]];
    NSLog(@"will bang box 3");
    [box3.hotInlet input:[BSDBang bang]];
    NSLog(@"will change box 1 value to 10");
    [box1.coldInlet input:@(10)];
    NSLog(@"will bang box 1");
    [box1.hotInlet input:[BSDBang bang]];
}

@end
