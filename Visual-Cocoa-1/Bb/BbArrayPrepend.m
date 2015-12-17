//
//  BbArrayPrepend.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbArrayPrepend.h"

@implementation BbArrayPrepend

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
    self.name = @"arr prepend";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSArray *result = nil;
        id toPrepend = [inlets.lastObject getValue];
        NSMutableArray *prependTo = [(NSArray *)hotValue mutableCopy];
        if (toPrepend) {
            [prependTo insertObject:toPrepend atIndex:0];
            result = prependTo;
        }
        return result;
    };
}

@end
