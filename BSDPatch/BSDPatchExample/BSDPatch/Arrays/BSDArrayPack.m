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
    NSArray *args = arguments;
    if (args && [args isKindOfClass:[NSArray class]]) {
        NSInteger idx = 0;
        NSMutableArray *temp = nil;
        for (NSString *arg in args) {
            BSDInlet *inlet = nil;
            if (idx == 0) {
                inlet = [self hotInletForArg:arg index:idx];
            }else{
                inlet = [self inletForArg:arg index:idx];
            }
            
            [self addPort:inlet];
            if (!temp) {
                temp = [NSMutableArray array];
            }
            [temp addObject:inlet];
            idx ++;
        }
        
        if (temp) {
            self.orderedInlets = [NSArray arrayWithArray:temp];
        }
    }
}

- (BSDInlet *)inletForArg:(NSString *)arg index:(NSInteger)index;
{
    BSDInlet *inlet = nil;
    if ([arg isEqualToString:@"n"]) {
        inlet = [[BSDNumberInlet alloc]initCold];
    }else if ([arg isEqualToString:@"s"]){
        inlet = [[BSDStringInlet alloc]initCold];
    }else if ([arg isEqualToString:@"a"]){
        inlet = [[BSDArrayInlet alloc]initCold];
    }else if ([arg isEqualToString:@"d"]){
        inlet = [[BSDDictionaryInlet alloc]initCold];
    }else if ([arg isEqualToString:@"o"]){
        inlet = [[BSDInlet alloc]init];
    }
    
    inlet.name = [NSString stringWithFormat:@"%@-%@",@(index),arg];
    return inlet;
}

- (BSDInlet *)hotInletForArg:(NSString *)arg index:(NSInteger)index
{
    BSDInlet *inlet = nil;
    if ([arg isEqualToString:@"n"]) {
        inlet = [[BSDNumberInlet alloc]initHot];
    }else if ([arg isEqualToString:@"s"]){
        inlet = [[BSDStringInlet alloc]initHot];
    }else if ([arg isEqualToString:@"a"]){
        inlet = [[BSDArrayInlet alloc]initHot];
    }else if ([arg isEqualToString:@"d"]){
        inlet = [[BSDDictionaryInlet alloc]initHot];
    }else if ([arg isEqualToString:@"o"]){
        inlet = [[BSDInlet alloc]initHot];
    }
    inlet.delegate = self;
    inlet.name = [NSString stringWithFormat:@"%@-%@",@(index),arg];
    return inlet;
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
    BSDInlet *hot = self.orderedInlets.firstObject;
    if (inlet == hot) {
        [self calculateOutput];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    BSDInlet *hot = self.orderedInlets.firstObject;
    if (inlet == hot) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    if (!self.orderedInlets) {
        return;
    }
    NSMutableArray *output = nil;
    for (BSDInlet *inlet in self.orderedInlets) {
        id value = inlet.value;
        if (value != nil) {
            if (!output) {
                output = [NSMutableArray array];
            }
            
            [output addObject:value];
        }else{
            output = nil;
            return;
        }
    }
    
    if (output) {
        [self.mainOutlet output:output];
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
