//
//  BbArrayElement.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbArrayElement.h"

@implementation BbArrayElement

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObject:@(BbValueType_Array)];
    }else if (port == self.coldInlet){
        return [NSSet setWithObject:@(BbValueType_Number)];
    }
    
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"arr elem";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        id result = nil;
        NSNumber *index = [inlets.lastObject getValue];
        NSMutableArray *array = [(NSArray *)hotValue mutableCopy];
        if (index && index.unsignedIntegerValue < array.count) {
            result = array[index.unsignedIntegerValue];
        }
        return result;
    };
}

@end
