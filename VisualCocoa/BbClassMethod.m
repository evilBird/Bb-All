//
//  BbClassMethod.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbClassMethod.h"
#import "BbObject+EntityParent.h"
#import "NSObject+Bb.h"
#import "NSInvocation+Bb.h"

@implementation BbClassMethod

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    NSArray *types = nil;
    NSUInteger portIndex = [self indexOfPort:port];
    switch (portIndex) {
        case 0:
            types = @[@(BbValueType_Array)];
            break;
            case 1:
            types = @[@(BbValueType_String)];
            break;
        default:
            return nil;
            break;
    }
    
    return [NSSet setWithArray:types];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    if (arguments) {
        self.name = [arguments toString];
        [self.coldInlet input:[arguments toString]];
    }else{
        self.name = @"cls method";
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets)
    {
        id result = nil;
        NSString *className = [[inlets[1] getValue]copy];
        NSMutableArray *methodInfo = [hotValue mutableCopy];
        NSString *selectorName = [[methodInfo.firstObject toString]copy];
        NSArray *args = nil;
        if (methodInfo.count > 1) {
            [methodInfo removeObjectAtIndex:0];
            args = methodInfo.mutableCopy;
        }
        result = [NSInvocation doClassMethod:className
                                selectorName:selectorName
                                        args:args];
        return result;
    };
}

@end
