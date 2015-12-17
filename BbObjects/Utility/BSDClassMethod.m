//
//  BSDClassMethod.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/12/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import "BSDClassMethod.h"
#import "NSInvocation+Bb.h"

@interface BSDClassMethod()

@property (nonatomic,strong)id returnVal;

@end


@implementation BSDClassMethod
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"cls method";
    
    self.selectorInlet = [[BSDInlet alloc]initCold];
    self.selectorInlet.name = @"selector";
    [self addPort:self.selectorInlet];
    
    self.argumentsInlet = [[BSDInlet alloc]initCold];
    self.argumentsInlet.name = @"arguments";
    [self addPort:self.argumentsInlet];
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSString *className = self.coldInlet.value;
    NSString *selectorName = self.selectorInlet.value;
    NSArray *arguments = self.argumentsInlet.value;
    
    if ( nil == className || nil == selectorName  )  {
        return;
    }
    
    id output = nil;
    
    if ( nil != arguments ) {
        if ( ![arguments isKindOfClass:[NSArray class]] ) {
            id arg = self.argumentsInlet.value;
            arguments = @[arg];
        }
    }
    
    output = [NSInvocation doClassMethod:className selectorName:selectorName args:arguments];
    
    if (nil != output) {
        [self.mainOutlet output:output];
    }else{
        [self.mainOutlet output:[BSDBang bang]];
    }
    
}

@end
