//
//  BSDRoute.m
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDRoute.h"
#import "BSDCollectionInlet.h"

@implementation BSDRoute

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"route";
    self.coldInlet.open = NO;
    if ([arguments isKindOfClass:[NSArray class]]) {
        NSArray *routeKeys = arguments;
        for (NSString *aRouteKey in routeKeys) {
            
            [self addOutletForRouteKey:aRouteKey];
        }
    }
    
    else if ([arguments isKindOfClass:[NSDictionary class]]){
        NSDictionary *routeKeysAndInlets = arguments;
        for (NSString *aRouteKey in routeKeysAndInlets.allKeys) {
            BSDInlet *anInlet = routeKeysAndInlets[aRouteKey];
            [self addOutletForRouteKey:aRouteKey connectToInlet:anInlet];
        }
    }else if ([arguments isKindOfClass:[NSString class]]){
        [self addOutletForRouteKey:arguments];
    }
    
    self.passThroughOutlet = [[BSDOutlet alloc]init];
    self.passThroughOutlet.name = @"pass through outlet";
    [self addPort:self.passThroughOutlet];
}

- (BSDInlet *)makeLeftInlet
{
    BSDInlet *inlet = [[BSDCollectionInlet alloc]initHot];
    inlet.name = @"hot";
    return inlet;
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
        if (![arr.firstObject isKindOfClass:[NSString class]] || arr.count == 0) {
            return;
        }
        
        NSString *routeKey = arr.firstObject;
        BSDOutlet *anOutlet = [self outletForRouteKey:routeKey];
        if (anOutlet != nil) {
            if (arr.count < 2) {
                [anOutlet output:[BSDBang bang]];
            }else if (arr.count == 2){
                [anOutlet output:arr[1]];
            }else {
                [arr removeObject:arr.firstObject];
                [anOutlet output:arr];
            }
        }else{
            [self.passThroughOutlet output:arr];
        }
        
    }
}

- (BSDOutlet *)addOutletForRouteKey:(NSString *)routeKey
{
    BSDOutlet *outlet = [[BSDOutlet alloc]init];
    outlet.name = routeKey;
    [self addPort:outlet];
    return outlet;
}

- (BSDOutlet *)addOutletForRouteKey:(NSString *)routeKey connectToInlet:(BSDInlet *)inlet
{
    BSDOutlet *outlet = [self addOutletForRouteKey:routeKey];
    [outlet connectToInlet:inlet];
    return outlet;
}

- (BSDOutlet *)outletForRouteKey:(NSString *)aRouteKey
{
    return [self outletNamed:aRouteKey];
}

@end
