//
//  BSDPointer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDInstanceMethod.h"
#import "NSInvocation+Bb.h"

@interface BSDInstanceMethod ()

@property (nonatomic,strong)id returnVal;

@end

@implementation BSDInstanceMethod

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"i method";    
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
    id pointer = self.coldInlet.value;
    NSString *selectorName = self.selectorInlet.value;
    NSArray *arguments = self.argumentsInlet.value;
    
    if ( nil == pointer || nil == selectorName) {
        return;
    }
    
    if ( nil != arguments ) {
        if ( ![arguments isKindOfClass:[NSArray class]] ) {
            id arg = self.argumentsInlet.value;
            arguments = @[arg];
        }
    }
    
    
    id output = [NSInvocation doInstanceMethodTarget:pointer selectorName:selectorName args:arguments];
    
    if (output) {
        self.returnVal = output;
        [self.mainOutlet output:self.returnVal];
    }else{
        [self.mainOutlet output:[BSDBang bang]];
    }
    
    self.coldInlet.value = nil;
}


@end
