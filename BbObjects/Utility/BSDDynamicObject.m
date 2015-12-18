//
//  BSDDynamicObject.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/10/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDDynamicObject.h"
#import "BSD2WayPort.h"
#import "BSDObjectLookup.h"

@interface BSDDynamicObject ()

@property (nonatomic,strong)BSDObject *myObject;
@property (nonatomic,strong)BSD2WayPort *hotInletBridgePort;
@property (nonatomic,strong)BSD2WayPort *coldInletBridgePort;
@property (nonatomic,strong)BSD2WayPort *mainOutletBridgePort;
@property (nonatomic,strong)BSDRoute *coldInletRouter;
@property (nonatomic,strong)NSString *className;
@property (nonatomic,strong)NSString *patchAlias;

@end

@implementation BSDDynamicObject

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Dynamic";
    self.hotInletBridgePort = [[BSD2WayPort alloc]initWithArguments:nil];
    self.coldInletBridgePort = [[BSD2WayPort alloc]initWithArguments:nil];
    [self.coldInlet forwardToPort:self.coldInletBridgePort.inlets.firstObject];
    self.mainOutletBridgePort = [[BSD2WayPort alloc]initWithArguments:nil];
    [self.mainOutletBridgePort.mainOutlet forwardToPort:self.mainOutlet];
    
    self.coldInletRouter = nil;
    self.myObject = nil;
    
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        if ([value isKindOfClass:[NSArray class]]){
            NSMutableArray *copy = [value mutableCopy];
            id first = copy.firstObject;
            if ([first isKindOfClass:[NSString class]] && [first isEqualToString:@"make"])
            {
                [copy removeObjectAtIndex:0];
                [self makeObjectWithArray:copy];
            }else{
                [self.hotInletBridgePort.hotInlet input:value];
            }
        }else{
            [self.hotInletBridgePort.hotInlet input:value];
        }
    }
}

- (void)cleanUpMyObject
{
    if (!self.myObject) {
        return;
    }
    NSInteger inletCount = [self.myObject inlets].count;
    if (inletCount > 0) {
        [self.hotInletBridgePort.mainOutlet disconnectFromInlet:self.myObject.inlets.firstObject];
        
    }
    NSInteger outletCount = [self.myObject outlets].count;
    if (outletCount > 0) {
        [self.myObject.mainOutlet disconnectFromInlet:self.mainOutletBridgePort.inlets.firstObject];
    }
    
    if (outletCount > 1 && self.coldInletRouter) {
        [self.coldInletBridgePort.outlets.firstObject disconnectFromInlet:self.coldInletRouter.hotInlet];
        [self.coldInletRouter tearDown];
        self.coldInletRouter = nil;
    }
    
    [self.myObject tearDown];
    self.myObject = nil;
    self.className = nil;
    self.patchAlias = nil;
}

- (void)makeObjectWithArray:(NSArray *)array
{
    if (!array || !array.count) {
        return;
    }
    
    [self cleanUpMyObject];
    
    NSInteger count = array.count;
    NSString *className = nil;
    NSArray *creationArgs = nil;
    NSMutableArray *arrCopy = array.mutableCopy;
    NSString *classString = arrCopy.firstObject;
    className = [self classNameFromString:classString];
    self.className = className;
    if (!className) {
        NSLog(@"error: could not find the class for string %@",classString);
        return;
    }
    if (count > 1) {
        [arrCopy removeObjectAtIndex:0];
        creationArgs = arrCopy;
        if ([self.className isEqualToString:@"BSDCompiledPatch"]) {
            NSString *patchString = creationArgs.firstObject;
            self.patchAlias = [self patchAliasFromString:patchString];
        }
    }
    
    [self makeObjectWithClass:className withArgs:creationArgs];
    [self connectMyObjectInlets];
    [self connectMyObjectOutlets];
}

- (NSString *)classNameFromString:(NSString *)string
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    NSArray *classList = [lookup classList];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[cd] %@",string];
    NSArray *filtered = [classList filteredArrayUsingPredicate:predicate];
    if (filtered) {
        return filtered.firstObject;
    }
    
    return nil;
}

- (NSString *)patchAliasFromString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    
    NSArray *components = [string componentsSeparatedByString:@"."];
    NSMutableArray *copy = components.mutableCopy;
    if ([copy.lastObject isEqualToString:@"bb"]) {
        [copy removeLastObject];
    }
    
    return copy.lastObject;
}

- (void)makeObjectWithClass:(NSString *)className withArgs:(NSArray *)args
{
    if (!className || ![className isKindOfClass:[NSString class]]) {
        return;
    }
    
    const char *class = [className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    if (![instance respondsToSelector:aSelector]) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    
    if (args && ![args isKindOfClass:[NSArray class]]) {
        id a = args;
        args = [NSArray arrayWithObject:a];
    }
    
    if (args != nil) {
        NSArray *a = args;
        if (a.count == 1) {
            id arg = a.firstObject;
            [invocation setArgument:&arg atIndex:2];
        }else{
            
            [invocation setArgument:&a atIndex:2];
        }
    }
    
    [invocation invoke];
    self.myObject = instance;
}

- (void)connectMyObjectInlets
{
    NSInteger inletCount = self.myObject.inlets.count;
    [self.hotInletBridgePort.mainOutlet connectToInlet:self.myObject.inlets.firstObject];
    
    if (inletCount > 1) {
        NSMutableArray *inletRouteArray = nil;
        for (NSInteger i = 1; i < inletCount; i ++) {
            if (!inletRouteArray) {
                inletRouteArray = [NSMutableArray array];
            }
            
            [inletRouteArray addObject:@(i)];
        }
        
        self.coldInletRouter = [[BSDRoute alloc]initWithArguments:inletRouteArray];
        for (NSInteger i = 1; i < inletCount; i ++) {
            BSDInlet *inlet = [self.myObject inlets][i];
            BSDOutlet *outlet = [self.coldInletRouter outletForRouteKey:@(i)];
            [outlet connectToInlet:inlet];
        }
        
        [self.coldInletBridgePort.mainOutlet connectToInlet:self.coldInletRouter.hotInlet];
    }
}

- (void)connectMyObjectOutlets
{
    NSArray *outlets = self.myObject.outlets;
    if (!outlets || !outlets.count) {
        return;
    }
    __weak BSDDynamicObject *weakself = self;
    NSInteger index = 0;
    for (BSDOutlet *outlet in self.myObject.outlets) {
        outlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
            id value = outlet.value;
            NSMutableArray *output = nil;
            NSString *outletkey = [NSString stringWithFormat:@"%@",@(index)];
            NSString *objectkey = nil;
            if (weakself.patchAlias) {
                objectkey = [weakself.patchAlias lowercaseString];
            }else{
                objectkey = [weakself.className lowercaseString];
            }
            
            if (value && objectkey && outletkey) {
                output = [NSMutableArray array];
                [output addObject:objectkey];
                [output addObject:outletkey];
                [output addObject:value];
                [weakself.mainOutletBridgePort.mainOutlet output:output.mutableCopy];
            }
        };
        
        index++;
    }
}

@end
