//
//  BSDArraySplit.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbArraySplit.h"

@implementation BbArraySplit

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
    [self addPort:[BbOutlet newOutletNamed:@"remainder"]];
    self.name = @"split arr";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    BbCalculateOutputBlock block;
    switch (index) {
        case 1:
            block = ^(id hotValue, NSArray *inlets){
                NSArray *toSplit = hotValue;
                NSNumber *splitIndex = [inlets.lastObject getValue];
                NSArray *result = nil;
                NSRange remainderRange;
                remainderRange.location = splitIndex.unsignedIntegerValue;
                remainderRange.length = (toSplit.count - splitIndex.unsignedIntegerValue);
                NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:remainderRange];
                result = [toSplit objectsAtIndexes:indices];
                return result;
            };
            break;
            
        default:
            block = ^(id hotValue, NSArray *inlets){
                NSArray *toSplit = hotValue;
                NSNumber *splitIndex = [inlets.lastObject getValue];
                NSArray *result = nil;
                NSRange remainderRange;
                remainderRange.location = 0;
                remainderRange.length = splitIndex.unsignedIntegerValue;
                NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:remainderRange];
                result = [toSplit objectsAtIndexes:indices];
                return result;
            };
            break;
    }
    
    return block;
}

@end
