//
//  BSDArrayMake.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayPack.h"

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
    NSMutableString *name = [NSMutableString stringWithString:@"pack"];
    NSArray *packingList = arguments;
    if (packingList && [packingList isKindOfClass:[NSArray class]]) {
        for (NSUInteger idx = 0; idx < packingList.count; idx ++) {
            BSDInlet *inlet = nil;
            if (idx == 0) {
                inlet = [[BSDInlet alloc]initHot];
                inlet.delegate = self;
            }else{
                inlet = [[BSDInlet alloc]initCold];
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
    self.hotInlet.open = NO;
    NSMutableArray *output = nil;
    for (BSDInlet *inlet in self.inlets) {
        id value = inlet.value;
        if (value == nil) {
            self.hotInlet.open = YES;
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
    self.hotInlet.open = YES;
}

@end
