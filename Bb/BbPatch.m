//
//  BbPatch.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"
#import "NSMutableString+Bb.h"
#import "NSMutableArray+Stack.h"
#import "BbPatch+Connections.h"

@implementation BbPatch

#pragma child objects

- (void)setupWithArguments:(id)arguments
{
    self.name = @"patch";
    self.creationArguments = [arguments toArray];
}

- (void)addChildObject:(BbObject *)childObject
{
    [super addChildObject:childObject];
    if ([childObject isKindOfClass:[BbProxyPort class]]) {
        [self addProxyPort:(BbProxyPort *)childObject];
    }
}

- (void)removeChildObject:(BbObject *)childObject
{
    [super removeChildObject:childObject];
    BOOL connectionsChanged = [self refreshConnections];
    if (connectionsChanged) {
        [self.view refresh];
    }
}

- (NSString *)textDescription
{
    NSMutableString *desc = [NSMutableString newDescription];
    [desc appendObject:[super textDescription]];
    if (self.connections){
        for (NSString *connectionId in self.connections.allKeys) {
            BbConnectionDescription *connection = [self.connections valueForKey:connectionId];
            if (connection.flag == BbConnectionDescriptionFlags_OK) {
                [desc appendObject:[connection textDescription]];
            }
        }
    }
    
    [desc appendThenSpace:@"#N"];
    [desc appendThenSpace:@"restore"];
    [desc appendThenSpace:self.creationArguments];
    [desc semiColon];
    [desc lineBreak];
    
    return desc;
}

- (NSArray *)UISize
{
    if (!self.view) {
        return nil;
    }
    
    CGSize size;
    size = [(NSView *)self.view intrinsicContentSize];
    return @[@(size.width),@(size.height)];
}

+ (NSString *)UIType
{
    return @"canvas";
}

+ (NSString *)stackInstruction
{
    return @"#N";
}

//Override so all ports are added with a proxy
- (void)addPort:(BbPort *)port {}

- (void)addProxyPort:(id)port
{
    NSUInteger portName = arc4random_uniform(1000);
    if ([port isKindOfClass:[BbProxyInlet class]]) {
        BbProxyInlet *proxy = port;
        BbInlet *inlet = [BbInlet newHotInletNamed:[NSString stringWithFormat:@"in-%@",@(portName)]];
        [self addInlet:inlet withProxy:proxy];
    }else if ([port isKindOfClass:[BbProxyOutlet class]]){
        BbProxyOutlet *proxy = port;
        BbOutlet *outlet = [BbOutlet newOutletNamed:[NSString stringWithFormat:@"out-%@",@(portName)]];
        [self addOutlet:outlet withProxy:proxy];
    }
}

@end

@implementation BbPatch (ProxyPorts)

- (void)addInlet:(BbInlet *)inlet withProxy:(BbProxyInlet *)proxy
{
    if (!inlet || (self.inlets_ && [self.inlets_ containsObject:inlet])) {
        return;
    }
    
    inlet.parent = self;
    proxy.parentPort = inlet;
    inlet.proxy = proxy;
    
    if (!self.inlets_) {
        self.inlets_ = [NSMutableArray array];
    }
    
    [self.inlets_ addObject:inlet];
}

- (void)addOutlet:(BbOutlet *)outlet withProxy:(BbProxyOutlet *)proxy
{
    if (!outlet || (self.outlets_ && [self.outlets_ containsObject:outlet])) {
        return;
    }
    
    outlet.parent = self;
    proxy.parentPort = outlet;
    outlet.proxy = proxy;
    
    if (!self.outlets_) {
        self.outlets_ = [NSMutableArray array];
    }
    
    [self.outlets_ addObject:outlet];
}

@end

