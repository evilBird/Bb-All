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
#import "BbCocoaPlaceholderObjectView.h"

@implementation BbCocoaPatchView

- (void)addPlaceholderObject
{
    CGRect frame = CGRectMake(200, 200, 100, 40);
    
    BbCocoaPlaceholderObjectView *placeholder = [[BbCocoaPlaceholderObjectView alloc]initWithFrame:frame];
    [self addSubview:placeholder];
    [placeholder.textField becomeFirstResponder];
}

- (BbObject *)addObjectAndViewWithText:(NSString *)text
{
    BbObjectDescription *desc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    return [self addObjectAndViewWithDescription:desc];
}

- (BbObject *)addObjectAndViewWithDescription:(BbObjectDescription *)description
{
    BbObject *object = [BbObject objectWithDescription:description];
    BbViewDescription *config = [BbViewDescription new];
    config.inlets = object.inlets.count;
    config.outlets = object.outlets.count;
    config.text = [NSString displayTextName:object.name args:description.BbObjectArgs];
    config.entityViewType = description.UIType;
    NSValue *centerValue = description.UICenter;
    CGPoint center;
    [centerValue getValue:&center];
    config.center = center;
    BbCocoaObjectView *view = [BbCocoaObjectView viewWithDescription:config inParent:self];
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
    return object;
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

- (NSBezierPath *)connectionPathFromArray:(NSArray *)array
{
    if (!array || array.count != 4) {
        return nil;
    }
    
    CGFloat x1,y1,x2,y2;
    x1 = [array[0] doubleValue];
    y1 = [array[1] doubleValue];
    x2 = [array[2] doubleValue];
    y2 = [array[3] doubleValue];
    
    CGPoint point = CGPointMake(x1, y1);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    point.x = x2;
    point.y = y2;
    [path lineToPoint:point];
    
    [path setLineWidth:4];
    [[NSColor blackColor]setStroke];
    
    return path;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSMutableArray *connections = self.connections.allObjects.mutableCopy;
    if (connections) {
        for (BbCocoaPatchGetConnectionArray block in connections) {
            NSBezierPath *connectionPath = [self connectionPathFromArray:block()];
            [connectionPath stroke];
        }
    }
    
    if (!self.drawThisConnection || self.drawThisConnection.count != 4) {
        return;
    }
    
    NSMutableArray *a = self.drawThisConnection.mutableCopy;
    NSBezierPath *path = [self connectionPathFromArray:a];
    [path stroke];
    
    self.drawThisConnection = nil;
    
}

@end
