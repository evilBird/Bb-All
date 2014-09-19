//
//  BSDPatchOutlet.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPatchOutlet.h"
#import "BSDInlet.h"
#import "BSDPort.h"

@interface BSDPatchOutlet ()<BSDPortDelegate>



@end


@implementation BSDPatchOutlet


- (instancetype)init
{
    self = [super init];
    if (self) {
        _inputElement = [[BSDInlet alloc]initHot];
        _inputElement.name = @"input element";
        [self observePort:_inputElement];
    }
    
    return self;
}

- (instancetype)initWithArguments:(id)arguments
{
    return [self init];
}

- (NSMutableArray *)inlets
{
    return [@[self.inputElement]mutableCopy];
}

- (NSMutableArray *)outlets
{

    return nil;
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
    if ([inletName isEqualToString:@"hot"] || [inletName isEqualToString:@"input element"]) {
        return self.inputElement;
    }
    return nil;
}

- (id)outletNamed:(NSString *)outletName
{
    if ([outletName isEqualToString:@"main"]) {
        return self;
    }
    return nil;
}

@end
