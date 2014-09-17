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
    
    for (NSDictionary *dict in objs) {
        BSDObjectDescription *desc = [BSDObjectDescription objectDescriptionWithDictionary:dict];
        [self createObjectWithDescription:desc];
        NSString *className = desc.className;
        if ([className isEqualToString:@"BSDPatchInlet"]) {
            self.patchInlet = self.objectGraph[desc.uniqueId];
            [self.hotInlet forwardToPort:[self.patchInlet inletNamed:@"hot"]];
        }else if ([className isEqualToString:@"BSDPatchOutlet"]){
            self.patchOutlet = self.objectGraph[desc.uniqueId];
        }
        
        if ([self.objectGraph[desc.uniqueId] respondsToSelector:@selector(view)]) {
            UIView *view = [self.objectGraph[desc.uniqueId] view];
            if (!self.views) {
                self.views = [NSMutableArray array];
            }
            [self.views addObject:view];
        }
    }
    
    [self.coldInlet setValue:self.views];
    
    NSString *key = @"superview";
    NSString *base = @"com.birdSound.BlockBox-UI.compiledPatchNeedsSomethingNotification";
    NSString *hollaBack = [NSString stringWithFormat:@"%@-reply-%@",base,self.objectId];
    NSDictionary *noticationInfo = @{@"key":key,
                                     @"hollaBack":hollaBack
                                     };
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCanvasResponseNotification:) name:hollaBack object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:base object:noticationInfo];
    
    for (NSDictionary *dict in connects) {
        BSDPortConnectionDescription *desc = [BSDPortConnectionDescription connectionDescriptionWithDictionary:dict];
        id sender = self.objectGraph[desc.senderParentId];
        id receiver = self.objectGraph[desc.receiverParentId];
        [[sender outletNamed:desc.senderPortName]connectToInlet:[receiver inletNamed:desc.receiverPortName]];
    }
    
    [self.hotInlet forwardToPort:[self.patchInlet inletNamed:@"hot"]];
    [self.patchOutlet forwardToPort:self.mainOutlet];

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
                
                UIView *oldSuper = aView.superview;
                
                [superview insertSubview:aView belowSubview:canvas];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        //[self.patchInlet input:value];
    }
}

- (void)calculateOutput
{
    
}


@end
