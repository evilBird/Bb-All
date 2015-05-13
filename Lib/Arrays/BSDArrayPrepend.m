//
//  BSDArrayPrepend.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArrayPrepend.h"

@implementation BSDArrayPrepend

- (instancetype)initWithPrependValue:(id)value
{
    return [super initWithArguments:value];
}

- (instancetype)initWithValue:(id)value
{
    return [super initWithArguments:value];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"prepend";
    
    if (arguments != NULL) {
        self.coldInlet.value = arguments;
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    id cold = self.coldInlet.value;

    if (hot == nil || cold == nil) {
        return;
    }
    
    NSMutableArray *output = [NSMutableArray array];
    [output addObject:cold];
    
    if ([hot isKindOfClass:[NSArray class]]) {
        id hotCopy = [hot mutableCopy];
        [output addObjectsFromArray:hotCopy];
    }else{
        [output addObject:hot];
    }
    
    [self.mainOutlet output:output];

}

- (void)test
{
    self.debug = YES;
    self.coldInlet.value = @"prepend me";
    self.hotInlet.value = @[@"sure",@"wish",@"someone",@"would",@"prepend",@"us"];
}

@end
