//
//  BbStrings.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbStrings.h"
#import "NSObject+Bb.h"
#import "NSArray+Bb.h"

@implementation BbStringObject : BbObject

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    NSArray *types = @[@(BbValueType_String)];
    return [NSSet setWithArray:types];
}

@end

@implementation BbStringLength :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    self.name = @"str len";
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
}

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]]) {
        return [super allowedTypesForPort:port];
    }else{
        NSArray *types = @[@(BbValueType_Number)];
        return [NSSet setWithArray:types];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSNumber *result = nil;
        NSString *hot = hotValue;
        result = @([hot length]);
        return result;
    };
}

@end

@implementation BbStringReplace :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    [self addPort:[BbInlet newHotInletNamed:@"hot_text"]];
    [self addPort:[BbInlet newColdInletNamed:@"toReplace"]];
    [self addPort:[BbInlet newColdInletNamed:@"replaceWith"]];
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
    
    self.name = @"str replace";
    
    if (arguments && [arguments isKindOfClass:[NSArray class]] && [arguments count] == 2) {
        NSArray *args = arguments;
        [self.inlets[1] input:args[0]];
        [self.inlets[2] input:args[1]];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSString *result = nil;
        NSString *hot = hotValue;
        NSString *toReplace = [inlets[1] getValue];
        NSString *replaceWith = [inlets[2] getValue];
        result = [hot stringByReplacingOccurrencesOfString:toReplace withString:replaceWith];
        return result;
    };
}

@end

@implementation BbStringComponents :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"str components";
}

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]]) {
        return [super allowedTypesForPort:port];
    }else{
        NSArray *types = @[@(BbValueType_Array)];
        return [NSSet setWithArray:types];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSArray *result = nil;
        NSString *hot = hotValue;
        NSString *cold = [inlets[1] getValue];
        result = [hot componentsSeparatedByString:cold];
        return result;
    };
}

@end

@implementation BbStringAppend :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"str append";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSString *result = nil;
        NSString *hot = hotValue;
        NSString *cold = [inlets[1] getValue];
        result = [hot stringByAppendingString:cold];
        return result;
    };
}

@end

@implementation BbStringPrepend :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"str prepend";
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSString *result = nil;
        NSString *hot = hotValue;
        NSString *cold = [inlets[1] getValue];
        result = [cold stringByAppendingString:hot];
        return result;
    };
}

@end

@implementation BbIsString

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"is string?";
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSUInteger isString = (NSUInteger)([hotValue isKindOfClass:[NSString class]]||[hotValue isKindOfClass:[NSMutableString class]] || [hotValue isKindOfClass:[NSAttributedString class]]);
        return @(isString);
    };
}

@end


@implementation BbToString
@end

@implementation BbArrayToString

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObject:@(BbValueType_Array)];
    }
    
    return nil;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"arr2str";
    [self addPort:[BbInlet newHotInletNamed:@"hot"]];
    [self addPort:[BbOutlet newOutletNamed:@"main"]];
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        NSString *result = nil;
        NSMutableString *temp = [[NSMutableString alloc]init];
        NSArray *hot = hotValue;
        NSUInteger idx = 0;
        for (id object in hot) {
            if ([object respondsToSelector:@selector(toString)]){
                [temp appendString:[object toString]];
            }else{
                [temp appendFormat:@"%@",object];
            }
            
            if (idx < (hot.count - 1)) {
                [temp appendString:@" "];
            }
            
            idx ++;
        }
        
        result = [NSString stringWithString:temp];
        return result;
    };
}

@end