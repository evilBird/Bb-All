//
//  BbArrayAppend.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbArrayAppend.h"

@implementation BbArrayAppend

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObject:@(BbValueType_Array)];
    }
    
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"arr append";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSArray *result = nil;
        id toAppend = [inlets.lastObject getValue];
        NSMutableArray *appendTo = [(NSArray *)hotValue mutableCopy];
        if (toAppend) {
            [appendTo addObject:toAppend];
            result = appendTo;
        }
        return result;
    };
}

@end
