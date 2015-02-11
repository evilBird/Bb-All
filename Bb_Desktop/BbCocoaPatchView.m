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
#import "BbCocoaPortView.h"

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
    config.entityViewType = description.UIType;
    //config.entityViewType = @"object";
    NSValue *centerValue = description.UICenter;
    CGPoint center;
    [centerValue getValue:&center];
    config.center = center;
    BbCocoaObjectView *view = [BbCocoaObjectView viewWithConfiguration:config parentView:self];
    object.view = (id<BbEntityView>)view;
    view.entity = object;
    
    for (NSUInteger i = 0; i<object.inlets.count; i++) {
        BbCocoaPortView *portview = view.inletViews[i];
        BbInlet *inlet = object.inlets[i];
        [portview setEntity:inlet];
        inlet.view = portview;
    }
    
    for (NSUInteger i = 0; i<object.outlets.count; i++) {
        BbCocoaPortView *portview = view.outletViews[i];
        BbOutlet *outlet = object.outlets[i];
        [portview setEntity:outlet];
        outlet.view = portview;
    }
    
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

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (!self.drawThisConnection || self.drawThisConnection.count != 4) {
        return;
    }
    
    NSMutableArray *a = self.drawThisConnection.mutableCopy;
    
    CGFloat x1,y1,x2,y2;
    x1 = [a[0] doubleValue];
    y1 = [a[1] doubleValue];
    x2 = [a[2] doubleValue];
    y2 = [a[3] doubleValue];
    
    CGPoint point = CGPointMake(x1, y1);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    [path lineToPoint:point];
    
    [path setLineWidth:4];
    [[NSColor blackColor]setStroke];
    [path stroke];
    
    self.drawThisConnection = nil;
}

@end
