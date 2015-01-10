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
#import "BSDPatchCompiler.h"
#import "BSDPatchManager.h"

@interface BSDCompiledPatch ()

@property (nonatomic,strong)NSMutableDictionary *objectGraph;
@property (nonatomic,strong)NSMutableDictionary *patchInlets;
@property (nonatomic,strong)NSMutableArray *views;

@end

@implementation BSDCompiledPatch

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"";
    NSString *patchName = nil;
    if (arguments) {
        if ([arguments isKindOfClass:[NSString class]]) {
            patchName = arguments;
            self.patchName = patchName;
        }else if ([arguments isKindOfClass:[NSArray class]]){
            NSArray *args = (NSArray *)arguments;
            patchName = args.firstObject;
            self.patchName = patchName;
            if (args.count > 1) {
                NSRange creationArgsRange;
                creationArgsRange.location = 1;
                creationArgsRange.length = args.count - 1;
                NSIndexSet *argsIndexSet = [NSIndexSet indexSetWithIndexesInRange:creationArgsRange];
                NSArray *ca = [args objectsAtIndexes:argsIndexSet];
                self.creationArgs = ca.mutableCopy;
                //NSLog(@"patch %@ has creation args: %@",patchName,self.creationArgs);
            }
        }
    }
    
    if (patchName) {
        NSString *patch = [self patchDescriptionWithName:patchName];
        self.patchName = patchName;
        if (patch) {
            [self loadPatchWithString:patch];
            NSArray *components = [patchName componentsSeparatedByString:@"."];
            NSInteger count = components.count;
            if ([patchName hasSuffix:@".bb"]) {
                self.name = components[count - 2];
            }else{
                self.name = components.lastObject;
            }
        }
    }
}

- (void)reloadPatch:(NSString *)desc
{
    [self.canvas clearCurrentPatch];
    [self loadPatchWithString:desc];
}

- (void)loadPatchWithString:(NSString *)string
{
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    self.canvas = [compiler restoreCanvasWithText:string creationArgs:self.creationArgs];
    
    NSInteger idx = 0;
    for (BSDInlet *inlet in self.canvas.inlets) {
        NSString *inletName = [NSString stringWithFormat:@"%@-%@",inlet.name,@(idx)];
        BSDInlet *myInlet = [self inletNamed:inletName];
        if (!myInlet) {
            myInlet = [[BSDInlet alloc]initHot];
            myInlet.name = [NSString stringWithFormat:@"%@-%@",inlet.name,@(idx)];
            myInlet.delegate = self;
            [self addPort:myInlet];
        }
        [myInlet forwardToPort:inlet];
        idx++;
    }
    idx = 0;
    for (BSDOutlet *outlet in self.canvas.outlets) {
        NSString *outletName = [NSString stringWithFormat:@"%@-%@",outlet.name,@(idx)];
        BSDOutlet *myOutlet = [self outletNamed:outletName];
        if (!myOutlet) {
            myOutlet = [[BSDOutlet alloc]init];
            myOutlet.name = outletName;
            [self addPort:myOutlet];
        }
        [outlet forwardToPort:myOutlet];
        idx++;
    }
    
    //[self.canvas loadBang];
}

- (void)setDelegate:(id<BSDCompiledPatchDelegate>)delegate
{

}

- (NSString *)patchDescriptionWithName:(NSString *)name
{
    /*
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"descriptions"];
    
    if (!savedPatches) {
        return nil;
    }
    
    if (!name || ![savedPatches.allKeys containsObject:name]) {
        return nil;
    }
    
    NSString *desc = savedPatches[name];
    */
    //NSLog(@"loading patch with name %@",name);
    NSString *patchName = nil;
    if ([name hasSuffix:@"bb"]) {
        patchName = name;
    }else{
        patchName = [name stringByAppendingString:@".bb"];
    }
    
    NSString *desc = [NSString stringWithString:[[BSDPatchManager sharedInstance]getPatchNamed:patchName]];
    
    if (!desc) {
        return nil;
    }
    
    return [NSString stringWithString:desc];
}

- (NSDictionary *)patchWithName:(NSString *)patchName
{
    /*
    NSDictionary *savedPatches = [NSUserDefaults valueForKey:@"patches"];
    if (!savedPatches) {
        return nil;
    }
    
    if (!patchName || ![savedPatches.allKeys containsObject:patchName]) {
        return nil;
    }
    
    NSMutableDictionary *copy = savedPatches.mutableCopy;
    
    return copy[patchName];
     */
    return nil;
}

- (void)loadPatchWithDictionary:(NSDictionary *)dictionary
{
    NSArray *objs = dictionary[@"objectDescriptions"];
    NSArray *connects = dictionary[@"connectionDescriptions"];
    NSMutableArray *inlets = nil;
    NSMutableArray *outlets = nil;
    NSMutableArray *loadBangs = nil;
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
            
        }else if ([desc.className isEqualToString:@"BSDLoadBang"]){
            if (!loadBangs) {
                loadBangs = [NSMutableArray array];
            }
            [loadBangs addObject:desc.uniqueId];
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
    
    if (loadBangs) {
        for (NSString *objectId in loadBangs) {
            BSDLoadBang *lb = self.objectGraph[objectId];
            if (lb && [lb isKindOfClass:[BSDLoadBang class]]) {
                [lb parentPatchFinishedLoading];
            }else{
                NSLog(@"load bang wasn't found");
            }
        }
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
        inlet.delegate = self;
        [self addPort:inlet];
        if (!self.patchInlets) {
            self.patchInlets = [NSMutableDictionary dictionary];
        }
        self.patchInlets[inlet.name] = patchInlet;
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
        outlet.name = [NSString stringWithFormat:@"patch outlet %@",[NSNumber numberWithInteger:idx].stringValue];
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

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    [(BSDInlet *)inlet.forwardPort input:[BSDBang bang]];
    /*
    NSString *inletName = inlet.name;
    if (self.patchInlets && [self.patchInlets.allKeys containsObject:inletName]) {
        BSDPatchInlet *patchInlet = self.patchInlets[inletName];
        [patchInlet input:[BSDBang bang]];
    }
     */
}
/*
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
