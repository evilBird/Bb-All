//
//  BbObject+CocoaView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+CocoaView.h"
#import "BbCocoaObjectView.h"
#import "BbParsers.h"
#import "BbObject+Decoder.h"
#import "BbUI.h"

@implementation BbObject (CocoaView)

+ (instancetype)objectAndViewWithText:(NSString *)text
{
    BbObjectDescription *desc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    return [BbObject objectAndViewWithDescription:desc];
}

+ (instancetype)objectAndViewWithDescription:(BbObjectDescription *)description
{
    BbObject *object = [BbObject objectWithDescription:description];
    BbObjectViewConfiguration *config = [BbObjectViewConfiguration new];
    config.inlets = object.inlets.count;
    config.outlets = object.outlets.count;
    config.text = object.className;
    config.entityViewType = @"object";
    NSValue *centerValue = description.UICenter;
    CGPoint center;
    [centerValue getValue:&center];
    config.center = center;
    id<BbEntityView> view = [BbCocoaObjectView viewWithConfiguration:config parentView:nil];
    object.view = view;
    return object;
}

- (void)setView:(id<BbEntityView>)view
{
    [super setView:view];
    [view setEntity:self];
}

@end
