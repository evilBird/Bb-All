//
//  BbInstanceMethod.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbInstanceMethod.h"
#import "BbObject+EntityParent.h"
#import "NSObject+Bb.h"
#import "NSInvocation+Bb.h"

@implementation BbInstanceMethod

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    NSArray *types = nil;
    NSUInteger portIndex = [self indexOfPort:port];
    switch (portIndex) {
        case 0:
            types = @[@(BbValueType_Array)];
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
        self.name = @"i method";
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets)
    {
        id result = nil;
        id instance = [inlets[1] getValue];
        if (instance == nil) {
            return result;
        }
        
        NSMutableArray *methodInfo = [hotValue mutableCopy];
        NSString *selectorName = [[methodInfo.firstObject toString]copy];
        NSArray *args = nil;
        if (methodInfo.count > 1) {
            [methodInfo removeObjectAtIndex:0];
            args = methodInfo.mutableCopy;
        }
        
        result = [NSInvocation doInstanceMethodTarget:instance
                                         selectorName:selectorName
                                                 args:args];
        if (result == nil) {
            result = instance;
        }
        return result;
    };
}

@end
