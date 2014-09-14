//
//  BSDCanvasCompiler.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCanvasCompiler.h"
#import "BSDCanvas.h"
#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import "BSDGraphBox.h"
#import "BSDObjectDescription.h"
#import "BSDPortConnectionDescription.h"
#import <objc/runtime.h>
#import "BSDPatch.h"
#import "BSDCompiledPatch.h"

@interface BSDCanvasCompiler ()

@property (nonatomic,strong)NSMutableDictionary *objectGraph;
@property (nonatomic,strong)NSMutableSet *objectDescriptions;
@property (nonatomic,strong)NSMutableSet *connectionDescriptions;

@end

@implementation BSDCanvasCompiler

+ (BSDCanvasCompiler *)compiler
{
    return [[BSDCanvasCompiler alloc]init];
}

- (BSDCompiledPatch *)compileCanvas
{
    NSMutableString *output = [[NSMutableString alloc]initWithFormat:@"\n\nBSDCANVAS COMPILED\n"];

    self.objectDescriptions = nil;
    self.objectDescriptions = [[NSMutableSet alloc]init];
    self.connectionDescriptions = nil;
    self.connectionDescriptions = [[NSMutableSet alloc]init];

    BSDCanvas *canvas = [self.delegate canvas];

    for (BSDGraphBox *gb in canvas.graphBoxes) {
        [output appendFormat:@"\n\nGRAPH BOX\n\tTYPE: %@\n\tID:%@\n",gb.className,[gb uniqueId]];
        BSDObjectDescription *desc = [[BSDObjectDescription alloc]init];
        desc.className = gb.className;
        desc.uniqueId = gb.uniqueId;
        [self.objectDescriptions addObject:desc];
        
        NSArray *connections = [gb connections];
        if (connections.count > 0) {
            [output appendFormat:@"\n\tCONNECTIONS\n"];
            for (BSDPortConnection *connect in connections) {
                NSString *summary = [NSString stringWithFormat:@"%@-->%@.%@ (%@))",connect.owner.portName,[connect.target.delegate parentClass],connect.target.portName,[connect.target.delegate parentId]];
                [output appendFormat:@"\n\t\t%@\n",summary];
                BSDPortConnectionDescription *cd = [[BSDPortConnectionDescription alloc]init];
                cd.senderParentId = [connect.owner.delegate parentId];
                cd.senderPortName = [connect.owner portName];
                cd.receiverParentId = [connect.target.delegate parentId];
                cd.receiverPortName = [connect.target portName];
                [self.connectionDescriptions addObject:cd];
            }
        }
    }
    
    NSLog(@"%@",output);
    [self instantiateObjectsWithDescriptions:self.objectDescriptions.allObjects];
    [self connectObjectGraphWithConnectionDescriptions:self.connectionDescriptions.allObjects];
    
    
    return [self compiledPatchDescriptions:self.objectDescriptions.allObjects withGraph:self.objectGraph];
}

- (BSDCompiledPatch *)compiledPatchDescriptions:(NSArray *)descriptions withGraph:(NSMutableDictionary *)graph
{
    BSDCompiledPatch *patch = [[BSDCompiledPatch alloc]initWithCanvas:[self.delegate canvas]];

    return patch;
}

- (void)instantiateObjectsWithDescriptions:(NSArray *)descriptions
{
    self.objectGraph = nil;
    self.objectGraph = [[NSMutableDictionary alloc]init];
    
    for (BSDObjectDescription *desc in descriptions) {
        [self addObjectToGraphWithObjectDescription:desc];
    }
}

- (void) addObjectToGraphWithObjectDescription:(BSDObjectDescription *)description
{
    const char *class = [description.className UTF8String];
    id c = objc_getClass(class);
    id s = objc_getClass([@"BSDObject" UTF8String]);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"init");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[s instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    [invocation invoke];
    self.objectGraph[description.uniqueId] = instance;
}

- (void)connectObjectGraphWithConnectionDescriptions:(NSArray *)descriptions
{
    for (BSDPortConnectionDescription *desc in descriptions) {
        [self.objectGraph[desc.senderParentId]
         connectOutlet:[self.objectGraph[desc.senderParentId]
                        outletNamed:desc.senderPortName]
         toInlet:[self.objectGraph[desc.receiverParentId]
                  inletNamed:desc.receiverPortName]];
        [self.objectGraph[desc.senderParentId] setDebug:YES];
        
    }
}

@end
