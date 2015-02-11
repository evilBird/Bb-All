//
//  BbCocoaPatchView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView.h"
#import "BbCocoaPatchView+Touches.h"
#import "BbParsers.h"
#import "BbObject+Decoder.h"
#import "BbUI.h"
#import "BbCocoaObjectView.h"
#import "BbObject+EntityParent.h"
#import "BbPatch.h"
#import "NSString+Bb.h"

@implementation BbCocoaPatchView


- (void)addObjectAndViewWithText:(NSString *)text
{
    BbObjectDescription *desc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    [self addObjectAndViewWithDescription:desc];
}

- (void)addObjectAndViewWithDescription:(BbObjectDescription *)description
{
    BbObject *object = [BbObject objectWithDescription:description];
    BbObjectViewConfiguration *config = [BbObjectViewConfiguration new];
    config.inlets = object.inlets.count;
    config.outlets = object.outlets.count;
    config.text = [NSString displayTextName:object.name args:description.BbObjectArgs];
    config.entityViewType = @"object";
    NSValue *centerValue = description.UICenter;
    CGPoint center;
    [centerValue getValue:&center];
    config.center = center;
    id<BbEntityView> view = [BbCocoaObjectView viewWithConfiguration:config parentView:self];
    object.view = view;
    [(BbPatch *)self.entity addChildObject:object];
}

- (void)commonInit
{
    if (self.entity == nil) {
        self.entity = (BbEntity *)[[BbPatch alloc]initWithArguments:nil];
    }
}

- (NSColor *)defaultColor
{
    return [NSColor whiteColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}


- (instancetype)initWithCoder:(NSCoder *)coder 
{
    self= [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

@end
