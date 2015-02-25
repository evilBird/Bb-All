//
//  BbPatch.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"
#import "NSMutableString+Bb.h"
#import "BbCocoaEntityView.h"

@implementation BbPatch

#pragma child objects


- (void)setupWithArguments:(id)arguments
{
    self.name = @"patch";
    self.creationArguments = [arguments toArray];
}

- (void)addConnectionsWithDescriptions:(NSArray *)descriptions
{
    for (BbConnectionDescription *desc in descriptions) {
        [self addConnectionWithDescription:desc];
    }
    
    [self refreshConnections];
}

- (BOOL)hasConnectionWithId:(NSString *)connectionId
{
    return [self.connections.allKeys containsObject:connectionId];
}

- (void)deleteConnectionWithId:(NSString *)connectionId
{
    BbConnectionDescription *connection = [self.connections valueForKey:connectionId];
    [self disconnectObject:connection.senderObjectIndex
                      port:connection.senderPortIndex
                fromObject:connection.receiverObjectIndex
                      port:connection.receiverPortIndex];
    BbConnectionDescription *new = connection;
    new.flag = BbConnectionDescriptionFlags_DELETE;
    
    [self.connections setObject:new forKey:connectionId];
    [self.view removeConnectionPathWithId:connectionId];
    [self refreshConnections];
    [self.view refresh];
    
    NSString *textDesc = [self textDescription];
    NSLog(@"\nPATCH DESCRIPTION UPDATE:\n%@",textDesc);
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@ || %K == %@",@"senderId",@(childObject.objectId),@"receiverId",@(childObject.objectId)];
    
    NSArray *toRemove = [self.connections.allValues filteredArrayUsingPredicate:pred];
    
    for (BbConnectionDescription *connection in toRemove) {
        
        NSString *connectionId = [@([connection connectionId])toString];
        [self disconnectObject:connection.senderObjectIndex
                          port:connection.senderPortIndex
                    fromObject:connection.receiverObjectIndex
                          port:connection.receiverPortIndex];
        BbConnectionDescription *new = connection;
        new.flag = BbConnectionDescriptionFlags_DELETE;
        
        [self.connections setObject:new forKey:connectionId];
        [self.view removeConnectionPathWithId:connectionId];
    }
    
    [super removeChildObject:childObject];
    [self refreshConnections];
    [self.view refresh];
    
    //[childObject tearDown];
    
    NSString *textDesc = [self textDescription];
    NSLog(@"\nPATCH DESCRIPTION UPDATE:\n%@",textDesc);
}

- (void)refreshConnections
{
    NSMutableDictionary *connections = nil;
    for (NSString *connectionId in self.connections.allKeys) {
        
        BbConnectionDescription *old = [self.connections valueForKey:connectionId];
        
        if (old.flag == BbConnectionDescriptionFlags_DELETE) {
            [self.connections removeObjectForKey:connectionId];
        }else{
            BbObject *sender = [self childWithId:old.senderId];
            BbOutlet *outlet = (BbOutlet *)[sender portWithId:old.senderPortId];
            BbObject *receiver = [self childWithId:old.receiverId];
            BbInlet *inlet = (BbInlet *)[receiver portWithId:old.receiverPortId];
            BbConnectionDescription *new = old;
            new.senderObjectIndex = [self indexOfChild:sender];
            new.senderPortIndex = [sender indexOfPort:outlet];
            new.receiverObjectIndex = [self indexOfChild:receiver];
            new.receiverPortIndex = [receiver indexOfPort:inlet];
            
            if (!connections) {
                connections = [NSMutableDictionary dictionary];
            }
            
            connections[connectionId] = new;
            
        }
    }
    
    self.connections = connections;
    
    [self.view patch:self connectionsDidChange:connections.allValues];
}

- (BbConnectionDescription *)descConnectionSender:(BbObject *)sender
                                           outlet:(BbOutlet *)outlet
                                       toReceiver:(BbObject *)receiver
                                            inlet:(BbInlet *)inlet
{
    BbConnectionDescription *desc = [BbConnectionDescription new];
    desc.parentId = self.objectId;
    desc.senderId = sender.objectId;
    desc.senderObjectIndex = [self indexOfChild:sender];
    desc.senderPortId = outlet.objectId;
    desc.senderPortIndex = [sender indexOfPort:outlet];
    desc.receiverId = receiver.objectId;
    desc.receiverObjectIndex = [self indexOfChild:receiver];
    desc.receiverPortId = inlet.objectId;
    desc.receiverPortIndex = [receiver indexOfPort:inlet];
    desc.ancestors = [self countAncestors]+1;
    desc.flag = BbConnectionDescriptionFlags_OK;
    
    return desc;
}

- (void)addConnectionWithDescription:(id)desc
{
    BbConnectionDescription *description = desc;
    [self connectObject:description.senderObjectIndex
                   port:description.senderPortIndex
               toObject:description.receiverObjectIndex
                   port:description.receiverPortIndex];
    
}

- (id)connectObject:(NSUInteger)senderObjectIndex
               port:(NSUInteger)senderPortIndex
           toObject:(NSUInteger)receiverObjectIndex
               port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    BbConnectionDescription *desc = nil;
    desc = [self descConnectionSender:sender
                               outlet:outlet
                           toReceiver:receiver
                                inlet:inlet];
    if (desc) {
        if (!self.connections) {
            self.connections = [[NSMutableDictionary alloc]init];
        }
        NSString *connectionId = [@([desc connectionId])toString];
        if ([self.connections.allKeys containsObject:connectionId]) {
            return nil;
        }
        [self.connections setValue:desc forKey:connectionId];
        [self connectOutlet:outlet toInlet:inlet];
    }
    
    return desc;
}

- (id)disconnectObject:(NSUInteger)senderObjectIndex
                    port:(NSUInteger)senderPortIndex
              fromObject:(NSUInteger)receiverObjectIndex
                    port:(NSUInteger)receiverPortIndex
{
    BbObject *sender = self.childObjects[senderObjectIndex];
    BbObject *receiver = self.childObjects[receiverObjectIndex];
    BbOutlet *outlet = sender.outlets[senderPortIndex];
    BbInlet *inlet = receiver.inlets[receiverPortIndex];
    
    [outlet disconnectFromInlet:inlet];
    
    BbConnectionDescription *desc = nil;
    desc = [self descConnectionSender:sender
                               outlet:outlet
                           toReceiver:receiver
                                inlet:inlet];
    
    NSString *connectionId = [@([desc connectionId])toString];
    
    if ([self.connections.allKeys containsObject:connectionId]) {
        //[self.connections removeObjectForKey:connectionId];
        desc.flag = BbConnectionDescriptionFlags_DELETE;
        return desc;
    }
    return nil;
}

- (void)connectOutlet:(BbOutlet *)outlet
              toInlet:(BbInlet *)inlet
{
    
    [outlet connectToInlet:inlet];
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

#import "SavedPatch.h"
#import "BbObject+Decoder.h"

@implementation BbCompiledPatch

- (void)setupWithArguments:(id)arguments
{
    self.name = @"compiled patch";
    if (arguments) {
        NSString *name = [arguments firstObject];
        NSString *patchName = nil;
        if ([name hasSuffix:@".bb"]) {
            patchName = name;
        }else{
            patchName = [name stringByAppendingPathExtension:@"bb"];
        }
        
        if (patchName) {
            NSString *text = [BbCompiledPatch textForSavedPatchWithName:patchName];
            if (text) {
                [self createChildObjectsWithText:text];
            }
        }
    }
}

- (void)createChildObjectsWithText:(NSString *)text
{
    NSMutableArray *rawDescriptions = [BbBasicParser descriptionsWithText:text].mutableCopy;
    [rawDescriptions removeObjectAtIndex:0];
    [rawDescriptions removeObjectAtIndex:(rawDescriptions.count - 1)];
    NSArray *descriptions = rawDescriptions;
    NSMutableArray *patches = [NSMutableArray array];
    NSMutableArray *childObjects = nil;
    NSMutableArray *connections = nil;
    
    [patches push:self];
    for (BbDescription *desc in descriptions) {
        if ([desc.stackInstruction isEqualToString:@"#N"]) {
            if ([desc.UIType isEqualToString:@"canvas"]) {
                BbPatch *patch = (BbPatch *)[BbObject objectWithDescription:(BbObjectDescription *)desc];
                patch.position = [(BbObjectDescription *)desc UIPosition];
                [patches push:patch];
            }else if ([desc.UIType isEqualToString:@"restore"]){
                BbPatch *patch = [patches pop];
                patch.name = [(BbObjectDescription *)desc BbObjectType];
                BbPatch *parent = [patches pop];
                if (parent) {
                    [parent addChildObject:patch];
                }
            }
        }else if ([desc.stackInstruction isEqualToString:@"#X"]){
            
            if ([desc.UIType isEqualToString:@"connect"]) {
                if (!connections) {
                    connections = [NSMutableArray array];
                }
                
                [connections addObject:desc];
                BbPatch *patch = [patches pop];
                [patch addConnectionWithDescription:desc];
                [patches push:patch];
                
            }else{
                
                BbObject *child = [BbObject objectWithDescription:(BbObjectDescription *)desc];
                child.position = [(BbObjectDescription *)desc UIPosition];
                if (!childObjects) {
                    childObjects = [NSMutableArray array];
                }
                
                BbPatch *patch = [patches pop];
                [patch addChildObject:child];
                [patches push:patch];
            }
        }
    }
}

+ (NSString *)textForSavedPatchWithName:(NSString *)patchName
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask,YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *patchPath = [documentsDirectory stringByAppendingPathComponent:patchName];
    NSURL *patchURL = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:patchPath])
    {
        patchURL = [NSURL fileURLWithPath:patchPath isDirectory:NO];
        NSLog(@"found saved patch %@ at path: %@",patchName,patchPath);
    }else{
        
        NSLog(@"couldn't find saved patch named %@ at path %@",patchName,patchPath);
    }
    
    NSString *result = nil;
    if (patchURL) {
        NSError *e = nil;
        NSStringEncoding encoding = 0;
        result = [NSString stringWithContentsOfURL:patchURL
                                      usedEncoding:&encoding
                                             error:&e];
        
        if (!e) {
            return result;
        }else{
            NSLog(@"error loading patch: %@",e.debugDescription);
        }
    }
    
    
    return nil;
}

+ (NSString *)stackInstruction
{
    return @"#X";
}

+ (NSString *)UIType
{
    return @"obj";
}

@end

#import "SavedPatch.h"

@implementation BbCompiledPatch (Loader)
/*
+ (BbCompiledPatch *)patchFromText:(NSString *)patchText creationArgs:(id)args
{
    BbCompiledPatch *patch = [SavedPatch compiledPatchFromText:patchText];
    patch.name = [args firstObject];
    patch.creationArguments = args;
    return patch;
}

+ (NSString *)textForSavedPatchName:(NSString *)name
{
    NSString *fileName = nil;
    if ([name hasSuffix:@".bb"]) {
        fileName = name;
    }else{
        fileName = [name stringByAppendingPathExtension:@"bb"];
    }
    
    return [SavedPatch textForSavedPatchWithName:fileName];
    
    return nil;
}
*/
@end
