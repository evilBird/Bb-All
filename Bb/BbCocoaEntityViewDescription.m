//
//  BbCocoaEntityViewDescription.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityViewDescription.h"
#import <Cocoa/Cocoa.h>
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
        NSPoint position;
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
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.alignment = NSCenterTextAlignment;
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
    return textAttributes;
}

+ (NSParagraphStyle *)paragraphStyle
{
    NSMutableParagraphStyle *result = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    result.alignment = NSCenterTextAlignment;
    return result;
}

@end
