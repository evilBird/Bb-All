//
//  BSDArrayLength.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbArrayLength.h"

@implementation BbArrayLength

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObject:@(BbValueType_Array)];
    }
    
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"arr len";
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue,NSArray *inlets){
        NSNumber *length = @(0);
        NSArray *array = hotValue;
        if (array) {
            length = @(array.count);
        }
        return length;
    };
}


@end
