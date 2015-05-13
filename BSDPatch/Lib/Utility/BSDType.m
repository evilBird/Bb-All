//
//  BSDType.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/22/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDType.h"

@implementation BSDType
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:nil];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"type";
    self.numberOutlet = [[BSDOutlet alloc]init];
    self.numberOutlet.name = @"number outlet";
    [self addPort:self.numberOutlet];
    
    self.stringOutlet = [[BSDOutlet alloc]init];
    self.stringOutlet.name = @"string";
    [self addPort:self.stringOutlet];
    
    self.arrayOutlet = [[BSDOutlet alloc]init];
    self.arrayOutlet.name = @"array";
    [self addPort:self.arrayOutlet];
    
    self.dictionaryOutlet = [[BSDOutlet alloc]init];
    self.dictionaryOutlet.name = @"dictionary";
    [self addPort:self.dictionaryOutlet];
    
    self.otherTypeOutlet = [[BSDOutlet alloc]init];
    self.otherTypeOutlet.name = @"other types";
    [self addPort:self.otherTypeOutlet];
    
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void)calculateOutput
{
    id input = self.hotInlet.value;
    if (input != nil) {
        
        if ([input isKindOfClass:[NSArray class]]) {
            [self.arrayOutlet output:input];
        }else if ([input isKindOfClass:[NSDictionary class]]){
            [self.dictionaryOutlet output:input];
        }else if ([input isKindOfClass:[NSNumber class]]){
            [self.numberOutlet output:input];
        }else if ([input isKindOfClass:[NSString class]]){
            [self.stringOutlet output:input];
        }else{
            [self.otherTypeOutlet output:input];
        }
        
    }
}

@end
