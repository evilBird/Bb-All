//
//  BSDPatchInlet.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchInlet.h"
#import "BSDOutlet.h"
@implementation BSDPatchInlet


- (instancetype)initWithArguments:(id)args
{
    return [self initHot];
}

- (instancetype)initHot
{
    self = [super initHot];
    if (self) {
        
        _outputElement = [[BSDOutlet alloc]init];
        _outputElement.name = @"output element";
        
    }
    return self;
}

- (instancetype)initCold
{
    self = [super initCold];
    if (self) {
        _outputElement = [[BSDOutlet alloc]init];
        _outputElement.name = @"output element";
    }
    
    return self;
}

- (void)input:(id)value
{
    if ([value isKindOfClass:[BSDBang class]]) {
        if (self.delegate) {
            [self.delegate portReceivedBang:self];
        }
        [self.outputElement setValue:[BSDBang bang]];
    }else if (self.isOpen) {
        self.value = value;
        [self.outputElement setValue:value];
    }
}

- (NSMutableArray *)inlets
{
    return nil;
}

- (NSMutableArray *)outlets
{
    return [@[self.outputElement]mutableCopy];
}

- (void)tearDown
{
    if (self.observedPorts) {
        for (BSDPort *port in self.observedPorts) {
            [port removeObserver:self forKeyPath:@"value"];
        }
    }
    
    self.observedPorts = nil;
    self.delegate = nil;
}

- (id)inletNamed:(NSString *)inletName
{
    if ([inletName isEqualToString:@"hot"]) {
        return self;
    }
    return nil;
}

- (id)outletNamed:(NSString *)outletName
{
    if ([outletName isEqualToString:@"output element"]||[outletName isEqualToString:@"main"]) {
        return self.outputElement;
    }
    
    return nil;
}

@end
