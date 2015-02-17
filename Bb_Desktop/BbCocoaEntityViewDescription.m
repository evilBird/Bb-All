//
//  BbCocoaEntityViewDescription.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityViewDescription.h"
#import <Cocoa/Cocoa.h>
@implementation BbCocoaEntityViewDescription

+ (BbCocoaEntityViewDescription *)placeholderEntityViewDescription
{
    BbCocoaEntityViewDescription *description = [[BbCocoaEntityViewDescription alloc]init];
    description.outlets = 0;
    description.inlets = 0;
    description.text = @"enter text";
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
