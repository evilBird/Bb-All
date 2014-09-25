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
/*
- (instancetype)initWithNumberOfInlets:(NSNumber *)numberOfInlets
{
    return [super initWithArguments:numberOfInlets];
}
- (instancetype)initAndConnectToOutlets:(NSArray *)outlets
{
    return [super initWithArguments:outlets];
}
*/

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"pack";
    NSString *args = arguments;
    NSMutableArray *temp = nil;
    if (args && [args isKindOfClass:[NSString class]]) {
        NSArray *components = [args componentsSeparatedByString:@" "];
        if (components) {
            NSInteger idx = 0;
            for (NSString *arg in components) {
                BSDInlet *inlet = nil;
                NSString *lower = [arg lowercaseString];
                if ([lower isEqualToString:@"n"]) {
                    if (idx == 0) {
                        inlet = [[BSDNumberInlet alloc]initHot];
                        inlet.delegate = self;
                    }else{
                        inlet = [[BSDNumberInlet alloc]initCold];
                    }
                    
                }else if ([lower isEqualToString:@"s"]){
                    if (idx == 0) {
                        inlet = [[BSDStringInlet alloc]initHot];
                        inlet.delegate = self;
                    }else{
                        inlet = [[BSDStringInlet alloc]initCold];
                    }
                }else if ([lower isEqualToString:@"a"]){
                    if (idx == 0) {
                        inlet = [[BSDArrayInlet alloc]initHot];
                        inlet.delegate = self;
                    }else{
                        inlet = [[BSDArrayInlet alloc]initCold];
                    }
                }else if ([lower isEqualToString:@"d"]){
                    if (idx == 0) {
                        inlet = [[BSDDictionaryInlet alloc]initHot];
                        inlet.delegate = self;
                    }else{
                        inlet = [[BSDDictionaryInlet alloc]initCold];
                    }
                }else{
                    if (idx == 0) {
                        inlet = [[BSDInlet alloc]initHot];
                        inlet.delegate = self;
                    }else{
                        inlet = [[BSDInlet alloc]initCold];
                    }
                    
                }
                if (!temp) {
                    temp = [NSMutableArray array];
                }
                
                inlet.name = [NSString stringWithFormat:@"%@",@(idx)];
                [temp addObject:inlet];
                [self addPort:inlet];
                idx ++;
            }
        }
        
        if (temp) {
            self.orderedInlets = [NSArray arrayWithArray:temp];
        }
    }
    //self.coldInlet.open = NO;
    /*
    if ([arguments isKindOfClass:[NSNumber class]]) {
        NSNumber *numberOfInlets = arguments;
        for (NSUInteger idx = 0; idx < numberOfInlets.integerValue; idx ++) {
            [self addInlet];
        }
    }else if ([arguments isKindOfClass:[NSArray class]]){
        NSArray *outlets = arguments;
        for (BSDOutlet *anOutlet in outlets) {
            [self addInletAndConnectToOutlet:anOutlet];
        }
    }
     */
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
    BSDInlet *firstInlet = self.orderedInlets.firstObject;
    if (inlet == firstInlet) {
        [self calculateOutput];
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    BSDInlet *firstInlet = self.orderedInlets.firstObject;
    if (inlet == firstInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSInteger sum = 0;
    NSMutableArray *temp = nil;
    
    for (BSDInlet *inlet in self.orderedInlets) {
        id value = inlet.value;
        if (value != nil) {
            if (!temp) {
                temp = [NSMutableArray array];
            }
            
            [temp addObject:value];
        }else{
            
            break;
        }
    }
    
    if (temp.count == self.orderedInlets.count) {
        [self.mainOutlet output:temp];
    }
    /*
    NSUInteger numberOfInlets = self.inlets.count - 2;
    NSMutableArray *outputArray = [[NSMutableArray alloc]initWithCapacity:numberOfInlets];
    for (NSUInteger idx = 0; idx < numberOfInlets; idx ++) {
        BSDInlet *inlet = [self inletAtIndex:@(idx)];
        if (inlet.value == NULL) {
            [outputArray addObject:[NSNull null]];
        }else{
            [outputArray addObject:inlet.value];
        }
    }
    
    [self.mainOutlet setValue:outputArray];
     */
}

- (BSDInlet *)inletAtIndex:(NSNumber *)index
{
    //offset index by 2 since we already have the hot and cold inlets
    NSUInteger i = index.integerValue + 2;
    NSString *inletName = [NSString stringWithFormat:@"%lu",(unsigned long)i];
    return [self inletNamed:inletName];
}

- (BSDInlet *)addInlet
{
    BSDInlet *inlet = [[BSDInlet alloc]init];
    inlet.name = [NSString stringWithFormat:@"%lu",(unsigned long)self.inlets.count];
    [self addPort:inlet];
    return inlet;
}

- (BSDInlet *)addInletAndConnectToOutlet:(BSDOutlet *)outlet
{
    BSDInlet *inlet = [self addInlet];
    [outlet connectToInlet:inlet];
    return inlet;
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
