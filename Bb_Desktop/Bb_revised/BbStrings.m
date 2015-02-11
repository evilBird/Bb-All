//
//  BbStrings.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/22/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbStrings.h"
#import "NSArray+Bb.h"

@implementation BbStringObject : BbObject

- (NSArray *)allowedTypesForPort:(BbPort *)port
{
    //NSString *string = [NSString string];
    //NSString *mutableString = [NSMutableString string];
    NSAttributedString *attrString = [[NSAttributedString alloc]init];
    //return [NSArray typeArrayWithObjects:@[string,attrString,mutableString]];
    return [NSArray typeArrayWithObjects:@[[NSString string],attrString,[NSMutableString string]]];

}

@end

@implementation BbStringLength :BbStringObject

- (void)setupWithArguments:(id)arguments
{
    self.name = @"str len";
    [self addPort:[BbInlet newHotInletNamed:kBbPortDefaultNameForHotInlet]];
    [self addPort:[BbOutlet newOutletNamed:kBbPortDefaultNameForMainOutlet]];
}

- (NSArray *)allowedTypesForPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]]) {
        return [super allowedTypesForPort:port];
    }else{
        return [NSArray typeArrayWithObjects:@[@(0)]];
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

- (NSArray *)allowedTypesForPort:(BbPort *)port
{
    if ([port isKindOfClass:[BbInlet class]]) {
        return [super allowedTypesForPort:port];
    }else{
        return [NSArray typeArrayWithObjects:@[[NSArray array],[NSMutableArray array]]];
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
    self.name = @"str append";
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