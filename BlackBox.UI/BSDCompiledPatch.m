//
//  BSDCompiledPatch.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCompiledPatch.h"
#import "BSDPort.h"
#import "BSDCanvas.h"
#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import "BSDGraphBox.h"
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"
#import <objc/runtime.h>
#import "BSDPatch.h"

@interface BSDCompiledPatch ()

@property (nonatomic,strong)NSMutableDictionary *objectGraph;

@end

@implementation BSDCompiledPatch

- (instancetype)initWithCanvas:(BSDCanvas *)canvas
{
    return [super initWithArguments:canvas];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Compiled patch";
    self.objectGraph = [NSMutableDictionary dictionary];
}

- (void)handleBoxUpdateNotification:(NSNotification *)notification
{
    NSDictionary *object = notification.object;
    if (!object) {
        return;
    }
    
    NSString *uniqueId = object[@"id"];
    NSNumber *eventType = object[@"event"];
    NSString *port = object[@"port"];
    id value = object[@"value"];
    
    id toUpdate = self.objectGraph[uniqueId];
    if (!toUpdate) {
        return;
    }
    
    if (eventType.integerValue == 1) {
        //input event
        [[toUpdate inletNamed:port]input:value];
    }
}

- (void)addObjectWithDescription:(BSDObjectDescription *)description
{
    const char *class = [description.className UTF8String];
    id c = objc_getClass(class);
    //id s = objc_getClass([@"BSDObject" UTF8String]);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    [invocation invoke];
    self.objectGraph[description.uniqueId] = instance;
    
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueDidChangeNotification",description.uniqueId];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleBoxUpdateNotification:) name:notificationName object:nil];
}

- (void)addConnectionWithDescription:(BSDPortConnectionDescription *)description
{
    if (!self.objectGraph || !description) {
        return;
    }
    BSDObject *sender = self.objectGraph[description.senderParentId];
    BSDObject *receiver = self.objectGraph[description.receiverParentId];
    
    if (!sender || !receiver) {
        return;
    }
    [sender setDebug:YES];
    [receiver setDebug:YES];
    [sender connectOutlet:[sender outletNamed:description.senderPortName] toInlet:[receiver inletNamed:description.receiverPortName]];
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",description.receiverParentId];
    sender.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        
        NSDictionary *info = @{@"id":description.receiverParentId,
                               @"event":@(0),
                               @"port":@"hot",
                               @"value":outlet.value
                               };
        [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:info];
        
    };
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
