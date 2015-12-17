//
//  NSObject+Bb.m
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "NSObject+Bb.h"
#import "NSString+Bb.h"
#import "BbBase.h"
#import "NSInvocation+Bb.h"

@implementation NSObject (Bb)

+ (NSUInteger)typeCode:(char *)type
{
    return [[NSString encodeType:type]hash];
}

- (BbValueType)BbValueType
{
    if ([self isNumber]) {
        return BbValueType_Number;
    }else if ([self isString]){
        return BbValueType_String;
    }else if ([self isArray]){
        return BbValueType_Array;
    }else if ([self isDictionary]){
        return BbValueType_Dictionary;
    }else if ([self isBang]){
        return BbValueType_Bang;
    }else{
        return BbValueType_Unknown;
    }
}
- (BOOL)isNumber
{
    return [self isKindOfClass:[NSNumber class]];
}

- (BOOL)isString
{
    return [self isKindOfClass:[NSString class]];
}
- (BOOL)isArray
{
    return [self isKindOfClass:[NSArray class]];
}
- (BOOL)isDictionary
{
    return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL)isBang
{
    return [self isKindOfClass:[BbBang class]];
}

- (NSSet *)conversions
{
    SEL selector = NSSelectorFromString(@"supportedConversions");
    if ([self respondsToSelector:selector]) {
        BbValueType valueType = [self BbValueType];
        switch (valueType) {
            case BbValueType_Array:
                return [(NSArray *)self supportedConversions];
                break;
            case BbValueType_Number:
                return [(NSNumber *)self supportedConversions];
                break;
                case BbValueType_String:
                return [(NSString *)self supportedConversions];
                break;
                case BbValueType_Dictionary:
                return [(NSDictionary *)self supportedConversions];
                break;
            default:
                return nil;
                break;
        }
    }else{
        return nil;
    }
}

- (BOOL)convertibleToType:(BbValueType)valueType
{
    NSSet *supportedConversions = [self conversions];
    if (!supportedConversions) {
        return NO;
    }
    
    return [supportedConversions containsObject:@(valueType)];
}

- (BbValueType)allowedConversionFromSet:(NSSet *)compatibleTypes
{
    NSSet *supportedConversions = [self conversions];
    if (!supportedConversions || !compatibleTypes) {
        return BbValueType_Unknown;
    }
    
    NSMutableSet *ctm = [NSMutableSet setWithArray:compatibleTypes.allObjects];
    [ctm intersectSet:ctm];
    if (ctm.count > 0) {
        return (BbValueType)[ctm.allObjects.firstObject integerValue];
    }else{
        return BbValueType_Unknown;
    }
}

- (id)convertToCompatibleTypeFromSet:(NSSet *)compatibleTypes
{
    BbValueType convertToThisType = [self allowedConversionFromSet:compatibleTypes];
    switch (convertToThisType) {
        case BbValueType_Unknown:
            return nil;
            break;
        case BbValueType_Number:
            return [NSInvocation doInstanceMethodTarget:self selectorName:@"toNumber" args:nil];
            break;
        case BbValueType_String:
            return [NSInvocation doInstanceMethodTarget:self selectorName:@"toString" args:nil];
            break;
        case BbValueType_Array:
            return [NSInvocation doInstanceMethodTarget:self selectorName:@"toArray" args:nil];
            break;
        case BbValueType_Dictionary:
            return [NSInvocation doInstanceMethodTarget:self selectorName:@"toDictionary" args:nil];
            break;
        case BbValueType_Bang:
            return [NSInvocation doInstanceMethodTarget:self selectorName:@"toBang" args:nil];
            break;
        default:
            return nil;
            break;
    }
}


+ (id)convertArray:(NSArray *)array toValueWithType:(NSString*)compatibleType
{
    if (!array || !array.count || !compatibleType || !compatibleType.length) {
        
    }
    
    return nil;
}

@end
