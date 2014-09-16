//
//  BSDPortConnectionDescription.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDPortConnectionDescription.h"

@implementation BSDPortConnectionDescription

+ (BSDPortConnectionDescription *)connectionDescriptionWithDictionary:(NSDictionary *)dictionary
{
    BSDPortConnectionDescription *desc = nil;

    
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"dictionary keys: %@, values: %@",dictionary.allKeys,dictionary.allValues);
    }
    
    if ([dictionary isKindOfClass:[NSArray class]]) {
        
        
    }
    
    
    desc = [[BSDPortConnectionDescription alloc]init];
    desc.senderPortName = dictionary[@"senderPortName"];
    desc.senderParentId = dictionary[@"senderParentId"];
    desc.receiverPortName = dictionary[@"receiverPortName"];
    desc.receiverParentId = dictionary[@"receiverParentId"];
    NSArray *points = dictionary[@"initialPoints"];
    NSDictionary *startDict = points.firstObject;
    NSDictionary *stopDict = points.lastObject;
    CGPoint o;
    o.x = [startDict[@"x"]doubleValue];
    o.y = [startDict[@"y"]doubleValue];
    CGPoint e;
    e.x = [stopDict[@"x"]doubleValue];
    e.y = [stopDict[@"y"]doubleValue];
    desc.initialPoints = @[[NSValue valueWithCGPoint:o],[NSValue valueWithCGPoint:e]];
    
    return desc;
}

- (NSDictionary *)dictionaryRespresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.senderPortName) {
        
        result[@"senderPortName"] = self.senderPortName;
    }
    
    if (self.senderParentId) {
        result[@"senderParentId"] = self.senderParentId;
    }
    
    if (self.receiverPortName) {
        result[@"receiverPortName"] = self.receiverPortName;
    }
    
    if (self.receiverParentId) {
        result[@"receiverParentId"] = self.receiverParentId;
    }
    
    if (self.initialPoints) {
        NSValue *start = self.initialPoints.firstObject;
        CGPoint o = start.CGPointValue;
        NSValue *stop = self.initialPoints.lastObject;
        CGPoint e = stop.CGPointValue;
        NSDictionary *startDict = @{@"x":@((double)o.x),
                                    @"y":@((double)o.y)
                                    };
        NSDictionary *stopDict = @{@"x":@((double)e.x),
                                   @"y":@((double)e.y)
                                   };
        NSArray *points = @[startDict,stopDict];
        result[@"initialPoints"] = points;
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
