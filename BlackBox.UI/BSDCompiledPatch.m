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
#import "NSUserDefaults+HBVUtils.h"

@interface BSDCompiledPatch ()

@property (nonatomic,strong)NSMutableDictionary *objectGraph;
@property (nonatomic,strong)NSMutableArray *views;

@end

@implementation BSDCompiledPatch

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"patch";
    NSString *patchName = arguments;
    if (patchName) {
        NSDictionary *patch = [self patchWithName:patchName];
        if (patch) {
            [self loadPatchWithDictionary:patch];
        }
    }
}

- (void)setDelegate:(id<BSDCompiledPatchDelegate>)delegate
{

}

- (NSDictionary *)patchWithName:(NSString *)patchName
{
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"patches"];
    if (!savedPatches) {
        return nil;
    }
    
    if (!patchName || ![savedPatches.allKeys containsObject:patchName]) {
        return nil;
    }
    
    return savedPatches[patchName];
}

- (void)loadPatchWithDictionary:(NSDictionary *)dictionary
{
    NSArray *objs = dictionary[@"objectDescriptions"];
    NSArray *connects = dictionary[@"connectionDescriptions"];
    NSMutableArray *inlets = nil;
    NSMutableArray *outlets = nil;
    for (NSDictionary *dict in objs) {
        BSDObjectDescription *desc = [BSDObjectDescription objectDescriptionWithDictionary:dict];
        [self createObjectWithDescription:desc];
        if ([desc.className isEqualToString:@"BSDPatchInlet"]) {
            if (!inlets) {
                inlets = [NSMutableArray array];
            }
            [inlets addObject:desc];
            
        }else if ([desc.className isEqualToString:@"BSDPatchOutlet"]){
            if (!outlets) {
                outlets = [NSMutableArray array];
            }
            [outlets addObject:desc];
            
        }
        
        for(NSDictionary *dict in connects) {
            BSDPortConnectionDescription *desc = [BSDPortConnectionDescription connectionDescriptionWithDictionary:dict];
            id sender = self.objectGraph[desc.senderParentId];
            id receiver = self.objectGraph[desc.receiverParentId];
            [[sender outletNamed:desc.senderPortName]connectToInlet:[receiver inletNamed:desc.receiverPortName]];
        }
    }
    
    if (inlets) {
        [self addPatchInletsWithDescriptions:inlets];
    }
    
    if (outlets) {
        [self addPatchOutletsWithDescriptions:outlets];
    }

}

- (void)addPatchInletsWithDescriptions:(NSArray *)patchInletDescriptions
{
    NSInteger idx = 0;
    NSSortDescriptor *leftToRight = [NSSortDescriptor sortDescriptorWithKey:@"xorigin" ascending:YES];
    NSArray *sortedDescriptions = [patchInletDescriptions sortedArrayUsingDescriptors:@[leftToRight]];
    for (BSDObjectDescription *desc in sortedDescriptions) {
        idx += 1;
        BSDInlet *inlet = [[BSDInlet alloc]initHot];
        BSDPatchInlet *patchInlet = self.objectGraph[desc.uniqueId];
        inlet.name = [NSString stringWithFormat:@"patch inlet %@",@(idx)];
        [self addPort:inlet];
        [inlet forwardToPort:[patchInlet inletNamed:@"hot"]];
    }
}

- (void)addPatchOutletsWithDescriptions:(NSArray *)patchOutletDescriptions
{
    NSInteger idx = 0;
    NSSortDescriptor *leftToRight = [NSSortDescriptor sortDescriptorWithKey:@"xorigin" ascending:YES];
    NSArray *sortedDescriptions = [patchOutletDescriptions sortedArrayUsingDescriptors:@[leftToRight]];
    for (BSDObjectDescription *desc in sortedDescriptions) {
        idx +=1;
        BSDOutlet *outlet = [[BSDOutlet alloc]init];
        BSDPatchOutlet *patchOutlet = self.objectGraph[desc.uniqueId];
        outlet.name = [NSString stringWithFormat:@"patch outlet %@",@(idx)];
        [self addPort:outlet];
        [patchOutlet forwardToPort:outlet];
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

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void) createObjectWithDescription:(BSDObjectDescription *)desc
{
    if (!self.objectGraph) {
        self.objectGraph = [NSMutableDictionary dictionary];
    }
    
    const char *class = [desc.className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    id creationArgs = nil;
    creationArgs = desc.creationArguments;
    if (creationArgs != nil) {
        NSArray *a = creationArgs;
        if (a.count == 1) {
            id arg = a.firstObject;
            [invocation setArgument:&arg atIndex:2];
        }else{
            
            [invocation setArgument:&a atIndex:2];
        }
    }
    
    [invocation invoke];
    self.objectGraph[desc.uniqueId] = instance;
    
}

- (void)handleCanvasResponseNotification:(NSNotification *)notification
{
    id response = notification.object;
    NSDictionary *dict = response;
    if (dict) {
        if ([dict.allKeys containsObject:@"superview"] && [dict.allKeys containsObject:@"canvas"]) {
            UIView *superview = dict[@"superview"];
            UIView *canvas = dict[@"canvas"];
            for (UIView *aView in self.views) {
                [superview insertSubview:aView belowSubview:canvas];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
/*
- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self.patchInlet input:[BSDBang bang]];
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        NSLog(@"compiled patch got bang");
    }
}
*/
- (void)calculateOutput
{
    
}

- (void)tearDown
{
    for (NSString *uniqueId in self.objectGraph.allKeys) {
        id obj = self.objectGraph[uniqueId];
        [obj tearDown];
    }
    
    [self.objectGraph removeAllObjects];
    self.objectGraph = nil;
    self.delegate = nil;
    [super tearDown];
}

@end
