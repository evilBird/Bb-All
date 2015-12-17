//
//  BSDObjectDescription.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObjectDescription.h"

static CGFloat kOffset = 20;

@implementation BSDObjectDescription

- (NSDictionary *)dictionaryRespresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    if (self.className) {
        result[kClassName] = self.className;
    }
    if (self.uniqueId) {
        result[kUUID] = self.uniqueId;
    }
    
    if (self.boxClassName) {
        result[kBoxClass] = self.boxClassName;
    }
    
    if (self.creationArguments) {
        result[kArgs] = self.creationArguments;
    }
    if (self.displayRect) {
        CGRect rect = self.displayRect.CGRectValue;
        NSDictionary *displayRect = @{@"x":@((double)rect.origin.x),
                                      @"y":@((double)rect.origin.y),
                                      @"width":@((double)rect.size.width),
                                      @"height":@((double)rect.size.height)
                                      };
        result[kRect] = displayRect;
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

- (CGFloat)xorigin
{
    if (!self.displayRect) {
        return 0;
    }
    CGRect rect = [self.displayRect CGRectValue];
    return rect.origin.x;
}

+ (BSDObjectDescription *)objectDescriptionWithDictionary:(NSDictionary *)dictionary
{
    return [BSDObjectDescription objectDescriptionWithDictionary:dictionary appendId:nil];
}

+ (BSDObjectDescription *)objectDescriptionWithDictionary:(NSDictionary *)dictionary appendId:(NSString *)appendId
{
    BSDObjectDescription *desc = nil;
    if (!dictionary || dictionary.allKeys.count == 0) {
        return desc;
    }
    
    NSArray *keys = dictionary.allKeys;
    
    desc = [[BSDObjectDescription alloc]init];
    if ([keys containsObject:kClassName]) {
        desc.className = dictionary[kClassName];
    }
    if ([keys containsObject:kUUID]) {
        if (appendId!=nil && appendId.length) {
            desc.uniqueId = [dictionary[kUUID] stringByAppendingString:appendId];
        }else{
            desc.uniqueId = dictionary[kUUID];
        }
    }
    if ([keys containsObject:kBoxClass]) {
        desc.boxClassName = dictionary[kBoxClass];
    }
    if ([keys containsObject:kArgs]) {
        desc.creationArguments = dictionary[kArgs];
    }
    if ([keys containsObject:kRect]) {
        NSDictionary *rectDictionary = dictionary[kRect];
        CGFloat offset = 0;
        if (appendId!=nil && appendId.length) {
            offset = kOffset;
        }
        CGRect rect;
        rect.origin.x = [rectDictionary[@"x"]doubleValue] + offset;
        rect.origin.y = [rectDictionary[@"y"]doubleValue] + offset;
        rect.size.width = [rectDictionary[@"width"]doubleValue];
        rect.size.height = [rectDictionary[@"height"]doubleValue];
        desc.displayRect = [NSValue valueWithCGRect:rect];
    }
    
    return desc;
}

- (BOOL)isEqual:(id)object
{
    return [self hash] == [object hash];
}

- (NSUInteger)hash
{
    return [self.uniqueId hash];
}

@end
