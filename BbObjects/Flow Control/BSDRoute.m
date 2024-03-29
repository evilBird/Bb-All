//
//  BSDRoute.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRoute.h"

@implementation BSDRoute

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"route";
    self.coldInlet.open = NO;
    if (arguments && [arguments isKindOfClass:[NSArray class]]) {
        NSArray *routeKeys = arguments;
        for (id aRouteKey in routeKeys) {
            
            [self addOutletForRouteKey:aRouteKey];
        }
    }else if (arguments && ([arguments isKindOfClass:[NSString class]]||[arguments isKindOfClass:[NSNumber class]])){
        
        [self addOutletForRouteKey:arguments];
    }
    
    self.passThroughOutlet = [[BSDOutlet alloc]init];
    self.passThroughOutlet.name = @"pass through outlet";
    [self addPort:self.passThroughOutlet];
}


- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void)calculateOutput
{
    id val = self.hotInlet.value;
    if (val == nil) {
        return;
    }
    
    if ([val isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *hot = [val mutableCopy];
        for (NSString *aRouteKey in hot.allKeys) {
            BSDOutlet *anOutlet = [self outletForRouteKey:aRouteKey];
            id value = [hot valueForKeyPath:aRouteKey];
            NSDictionary *output = @{aRouteKey:value};
            if (anOutlet != nil) {
                [anOutlet output:value];
            }else{
                [self.passThroughOutlet output:output];
            }
        }
        return;
    }
    if ([val isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [val mutableCopy];
        if (arr.count == 0) {
            return;
        }
        
        id routeKey = arr.firstObject;
        [arr removeObject:routeKey];
        BSDOutlet *anOutlet = [self outletForRouteKey:routeKey];
        if (anOutlet != nil) {
            if (arr.count == 0) {
                [anOutlet output:[BSDBang bang]];
            }else if (arr.count == 1){
                [anOutlet output:arr.firstObject];
            }else {
                [anOutlet output:arr];
            }
        }else{
            [arr insertObject:routeKey atIndex:0];
            [self.passThroughOutlet output:arr];
        }
        return;
    }
    if ([val isKindOfClass:[NSNumber class]]||[val isKindOfClass:[NSString class]]) {
        NSString *routeKey = [NSString stringWithFormat:@"%@",val];
        BSDOutlet *outlet = [self outletNamed:routeKey];
        if (outlet) {
            [outlet output:[BSDBang bang]];
        }
    }
}

- (BSDOutlet *)addOutletForRouteKey:(id)routeKey
{
    BSDOutlet *outlet = [[BSDOutlet alloc]init];
    outlet.name = [NSString stringWithFormat:@"%@",routeKey];
    [self addPort:outlet];
    return outlet;
}

- (BSDOutlet *)outletForRouteKey:(id)aRouteKey
{
    return [self outletNamed:[NSString stringWithFormat:@"%@",aRouteKey]];
}

@end
