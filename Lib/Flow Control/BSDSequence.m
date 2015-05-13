//
//  BSDSequence.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDSequence.h"

@interface BSDSequence ()

//@property (nonatomic,strong)NSMutableArray *outletsToSequence;

@end

@implementation BSDSequence

- (instancetype)initWithNumberOfOutlets:(NSNumber *)numberOfOutlets
{
    return [super initWithArguments:numberOfOutlets];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"sequence";
    self.coldInlet.open = NO;
    if ([arguments isKindOfClass:[NSNumber class]]) {
        NSNumber *numberOfOutlets = arguments;
        for (NSUInteger i = 0; i < numberOfOutlets.integerValue; i++) {
            
            if (!self.outlets) {
                self.outlets = [NSMutableArray array];
            }
            
            [self addOutlet];
            
        }
    }
}


- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (BSDOutlet *)makeLeftOutlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        NSInteger idx = self.outlets.count - 1;
        
        while (idx > -1) {
            BSDOutlet *anOutlet = self.outlets[idx];
            [anOutlet output:[BSDBang bang]];
            idx --;
        }
    }
}

- (void)calculateOutput
{
    NSInteger idx = self.outlets.count - 1;
    
    while (idx >= 0) {
        BSDOutlet *anOutlet = self.outlets[idx];
        id value = self.hotInlet.value;
        [anOutlet output:value];
        idx --;
    }
}

//add outlets
- (BSDOutlet *)addOutlet
{
    NSUInteger numberOfOutlets = self.outlets.count;
    BSDOutlet *anOutlet = [[BSDOutlet alloc]init];
    anOutlet.name = [NSString stringWithFormat:@"%lu",(unsigned long)numberOfOutlets];
    [self addPort:anOutlet];
    return anOutlet;
}
- (BSDOutlet *)addOutletAndConnectToInlet:(BSDInlet *)inlet
{
    BSDOutlet *outlet = [self addOutlet];
    [outlet connectToInlet:inlet];
    return outlet;
}

@end
