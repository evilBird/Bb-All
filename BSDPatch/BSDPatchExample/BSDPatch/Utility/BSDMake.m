//
//  BSDMake.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDMake.h"
#import "BSDObjectLookup.h"
#import "BSDView.h"

@interface BSDMake ()

@property (nonatomic,strong)NSString *className;
@property (nonatomic,strong)NSMutableDictionary *args;
@property (nonatomic,strong)UIView *superview;
@property (nonatomic,strong)UIView *canvas;

@end

@implementation BSDMake

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    NSString *class = arguments;
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    if (class && [class isKindOfClass:[NSString class]]) {
        self.name = @"make";
        self.className = [lookup classNameForString:class];
    }else{
        self.name = @"class";
    }
    
    self.argsInlet = [[BSDInlet alloc]initHot];
    self.argsInlet.name = @"args inlet";
    [self addPort:self.argsInlet];
}



- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        if (self.className) {
            
            [self makeObject];
            BSDObject *new = self.subobjects.lastObject;
            //BSDOutlet *leftOutlet = new.outlets.firstObject;
            [self.mainOutlet output:new];
        }
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.argsInlet) {
        if (value != NULL && [value isKindOfClass:[NSDictionary class]]) {
            if (!self.args) {
                self.args = [NSMutableDictionary dictionary];
            }
            
            NSMutableDictionary *newArgs = value;
            for (id aKey in newArgs) {
                id val = newArgs[aKey];
                self.args[aKey] = val;
            }
        }
    }
}

- (void)calculateOutput
{

}

- (UIView *)view
{
    return [UIView new];
}

- (void) makeObject
{
    
    if (!self.subobjects) {
        self.subobjects = [NSMutableArray array];
    }
    
    const char *class = [self.className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    id creationArgs = self.argsInlet.value;
    
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
    [self.subobjects addObject:instance];
    SEL setter = NSSelectorFromString(@"setterInlet");
    if ([instance respondsToSelector:setter]) {
        [[instance setterInlet]input:self.args];
    }
}

- (void)tearDown
{
    for (id subobj in self.subobjects) {
        [subobj tearDown];
    }
    
    [super tearDown];
    
}

@end
