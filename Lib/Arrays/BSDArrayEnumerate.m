//
//  BSDArrayDripSlow.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/3/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayEnumerate.h"
#import "BSDArrayInlet.h"

@implementation BSDArrayEnumerate

- (instancetype)initWithArray:(NSArray *)array
{
    return [super initWithArguments:array];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"array enum";
    NSArray *array = arguments;
    if (arguments) {
        self.coldInlet.value = array;
    }
    
    self.doneOutlet = [[BSDOutlet alloc]init];
    self.doneOutlet.name = @"doneOutlet";
    [self addPort:self.doneOutlet];
    
}

- (BSDInlet *)makeRightInlet
{
    BSDInlet *inlet = [[BSDArrayInlet alloc]initCold];
    inlet.name = @"cold";
    return inlet;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        
        [self calculateOutput];
    }

}

- (void)calculateOutput
{
    NSMutableArray *array = [self.coldInlet.value mutableCopy];
    if (array.count > 0) {
        id value = array.firstObject;
        NSRange newRange;
        newRange.location = 1;
        newRange.length = array.count - 1;
        [self.mainOutlet setValue:value];
        [self.coldInlet setValue:[array subarrayWithRange:newRange]];
        if (newRange.length == 0) {
            [self.doneOutlet setValue:[BSDBang bang]];
        }
    }else{
        [self.doneOutlet setValue:[BSDBang bang]];
    }
}

@end
