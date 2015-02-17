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
#import "PureLayout.h"
#import "BbCocoaEntityView.h"
#import "NSInvocation+Bb.h"
#import "BbCocoaHSliderView.h"

@implementation BbCocoaPatchView

- (id) addPlaceholderAtPoint:(CGPoint)point
{
    BbCocoaEntityViewDescription *placeholderDescription = [BbCocoaEntityViewDescription placeholderEntityViewDescription];
    placeholderDescription.normalizedPosition = [self normalizePoint:point];
    BbCocoaPlaceholderObjectView *placeholder = [[BbCocoaPlaceholderObjectView alloc]initWithDelegate:self
                                                                                      viewDescription:placeholderDescription inParent:self];
    [self moveEntityView:placeholder toPoint:point];
    return placeholder;
}

- (BbObject *)addObjectWithText:(NSString *)text
{
    BbObjectDescription *objDesc = (BbObjectDescription *)[BbBasicParser descriptionWithText:text];
    BbObject *object = [BbObject objectWithDescription:objDesc];
    if (!object) {
        return nil;
    }
    
    [self.patch addChildObject:object];
    BbCocoaEntityViewDescription *viewDesc = [[BbCocoaEntityViewDescription alloc]init];
    viewDesc.text = [NSString displayTextName:object.name args:objDesc.BbObjectArgs];
    viewDesc.entityViewType = objDesc.UIType;
    viewDesc.inlets = object.inlets.count;
    viewDesc.outlets = object.outlets.count;
    NSPoint normCenter;
    CGFloat normX = [objDesc.UIPosition.firstObject doubleValue];
    CGFloat normY = [objDesc.UIPosition.lastObject doubleValue];
    normCenter.x = normX;
    normCenter.y = normY;
    viewDesc.normalizedPosition = normCenter;
    BbCocoaObjectView *view = nil;
    view = [BbCocoaObjectView viewWithBbUIType:objDesc.UIType
                                        entity:object
                                   description:viewDesc
                                        parent:self];

    NSPoint viewPosition = [self scaleNormalizedPoint:view.normalizedPosition];
    [self moveEntityView:view toPoint:viewPosition];
    return object;
}

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    if (!self.entity) {
        self.entity = (BbEntity *)[[BbPatch alloc]initWithArguments:nil];
    }
    
    if (!self.viewDescription) {
        self.normalizedPosition = NSPointFromCGPoint(CGPointMake(50, 50));
    }
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    if (self.superview) {
        [self autoPinEdgesToSuperviewEdgesWithInsets:NSEdgeInsetsZero];
        [self refresh];
    }
}

- (BbPatch *)patch
{
    return (BbPatch *)self.entity;
}

- (NSColor *)defaultColor
{
    return [NSColor whiteColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}

- (NSSize)intrinsicContentSize
{
    return NSSizeFromCGSize(self.superview.bounds.size);
}

#pragma mark - BbPlaceholderViewDelegate

- (void)placeholder:(id)sender enteredText:(NSString *)text
{
    NSString *textDesc = [self textDescriptionWithText:text
                                   fromPlaceholderView:sender];
    if (textDesc) {
        [self swapPlaceholderView:sender withObjectCreatedFromText:textDesc];
    }
}

- (NSString *)textDescriptionWithText:(NSString *)text fromPlaceholderView:(BbCocoaPlaceholderObjectView *)p
{
    if (!text) {
        return nil;
    }
    
    NSArray *components = [text componentsSeparatedByString:@" "];
    NSString *className = [BbObject lookUpClassWithText:components.firstObject];
    if (!className) {
        return nil;
    }
    
    NSMutableString *textDesc = [[NSMutableString alloc]initWithString:@"#X"];
    [textDesc appendString:@" "];
    NSString *UIType = [NSInvocation doClassMethod:className
                                      selectorName:@"UIType"
                                              args:nil];
    [textDesc appendString:UIType];
    [textDesc appendString:@" "];
    [textDesc appendFormat:@"%.f %.f",p.normalizedPosition.x,p.normalizedPosition.y];
    [textDesc appendString:@" "];
    [textDesc appendString:className];
    [textDesc appendString:@" "];
    
    if (components.count > 1)
    {
        NSMutableArray *componentsCopy = components.mutableCopy;
        [componentsCopy removeObjectAtIndex:0];
        NSString *argsString = [NSString stringWithArray:componentsCopy];
        [textDesc appendString:@" "];
        [textDesc appendString:argsString];
    }
    
    [textDesc appendString:@";\n"];
    NSString *result = [NSString stringWithString:textDesc];
    return result;
}

- (void)swapPlaceholderView:(BbCocoaPlaceholderObjectView *)placeholderView
  withObjectCreatedFromText:(NSString *)text
{
    [placeholderView removeFromSuperviewWithoutNeedingDisplay];
    [self addObjectWithText:text];
}

#pragma mark - drawing methods

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
