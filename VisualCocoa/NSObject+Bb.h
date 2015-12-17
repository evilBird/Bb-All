//
//  NSObject+Bb.h
//  Bb_revised
//
//  Created by Travis Henspeter on 1/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+Bb.h"
#import "NSArray+Bb.h"
#import "NSString+Bb.h"
#import "NSNumber+Bb.h"

typedef NS_ENUM(NSInteger, BbValueType){
    BbValueType_Unknown = 0,
    BbValueType_Number = 1,
    BbValueType_String = 2,
    BbValueType_Array = 3,
    BbValueType_Dictionary = 4,
    BbValueType_Bang = 5
};

@interface NSObject (Bb)

+ (NSUInteger)typeCode:(char *)type;
- (BbValueType)BbValueType;
- (BOOL)isNumber;
- (BOOL)isString;
- (BOOL)isArray;
- (BOOL)isDictionary;
- (BOOL)isBang;
- (BOOL)convertibleToType:(BbValueType)valueType;
- (NSSet *)conversions;
- (BbValueType)allowedConversionFromSet:(NSSet *)compatibleTypes;
- (id)convertToCompatibleTypeFromSet:(NSSet *)compatibleTypes;


@end
