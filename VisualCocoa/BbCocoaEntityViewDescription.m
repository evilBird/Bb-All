//
//  BbCocoaEntityViewDescription.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityViewDescription.h"
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import "BbObject.h"
#import "NSString+Bb.h"

@implementation BbCocoaEntityViewDescription

+ (BbCocoaEntityViewDescription *)viewDescriptionForObject:(BbObject *)object
{
    BbCocoaEntityViewDescription *description = [[BbCocoaEntityViewDescription alloc]init];
    description.inlets = object.inlets.count;
    description.outlets = object.outlets.count;
    description.text = [NSString displayTextName:object.name args:object.creationArguments];
    description.entityViewType = [[object class]UIType];
    NSArray *positionArr = object.position;
    if (positionArr && positionArr.count == 2) {
#if TARGET_OS_IPHONE == 1
        CGPoint position;
#else
        NSPoint position;
#endif
        position.x = [positionArr.firstObject doubleValue];
        position.y = [positionArr.lastObject doubleValue];
        description.position = position;
    }
    
    return description;
}

+ (BbCocoaEntityViewDescription *)placeholderEntityViewDescription
{
    BbCocoaEntityViewDescription *description = [[BbCocoaEntityViewDescription alloc]init];
    description.outlets = 0;
    description.inlets = 0;
    description.text = @" ";
    description.entityViewType = @"placeholder";
    return description;
}

+ (NSDictionary *)textAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
#if TARGET_OS_IPHONE == 1
    UIFont *font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
    UIColor *color = [UIColor whiteColor];
    paragraphStyle.alignment = NSTextAlignmentCenter;
#else
    
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    paragraphStyle.alignment = NSCenterTextAlignment;
#endif
    
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
    return textAttributes;
}

+ (NSParagraphStyle *)paragraphStyle
{
    NSMutableParagraphStyle *result = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
#if TARGET_OS_IPHONE == 1
    result.alignment = NSTextAlignmentCenter;
#else
    result.alignment = NSCenterTextAlignment;
#endif
    return result;
}

@end
