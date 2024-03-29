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
#import "BbCocoaPatchView+Helpers.h"
#import "BbCocoaPatchView+Connections.h"
#import "NSMutableString+Bb.h"
#import "BbCocoaPatchView+Keys.h"

@implementation BbCocoaPatchView

+ (instancetype)patchViewWithPatch:(BbPatch *)patch inView:(id)view
{
    BbCocoaPatchView *patchView = [[BbCocoaPatchView alloc]initWithEntity:patch
                                                          viewDescription:nil
                                                                 inParent:view];
    
    patch.view = patchView;
    
    NSArray *children = patch.childObjects_.array;
    for (BbObject *object in children) {
        [patchView addViewForObject:object];
    }
    
    [patchView patch:patch connectionsDidChange:patch.connections.allValues];
    
    return patchView;
}

- (void)addViewForObject:(BbObject *)object
{
    BbCocoaObjectView *view = [BbCocoaObjectView viewWithObject:object
                                                         parent:self];
    VCPoint viewPosition = [self scaleNormalizedPoint:view.normalizedPosition];
    [self moveEntityView:view toPoint:viewPosition];
}

- (id) addPlaceholderAtPoint:(CGPoint)point
{
    BbCocoaEntityViewDescription *placeholderDescription = [BbCocoaEntityViewDescription placeholderEntityViewDescription];
    placeholderDescription.position = [self normalizePoint:point];
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
    BbCocoaObjectView *view = [BbCocoaObjectView viewWithObject:object
                                                         parent:self];
    VCPoint viewPosition = [self scaleNormalizedPoint:view.normalizedPosition];
    
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
#if TARGET_OS_IPHONE
        self.normalizedPosition = CGPointMake(50, 50);
#else
        self.normalizedPosition = NSPointFromCGPoint(CGPointMake(50, 50));
#endif
    }
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    if (self.superview) {
        [self autoPinEdgesToSuperviewEdgesWithInsets:VCEdgeInsetsZero];
        [self refresh];
    }
}

- (BbPatch *)patch
{
    return (BbPatch *)self.entity;
}

- (VCColor *)defaultColor
{
    return [VCColor whiteColor];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.9 alpha:1];
}

- (VCSize)intrinsicContentSize
{
    return self.superview.bounds.size;
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
    
    NSString *desc = nil;
    NSUInteger ancestors;
    ancestors = [self.patch countAncestors];
    NSMutableArray *compcopy = components.mutableCopy;
    NSArray *args = nil;
    
    if (compcopy.count > 1) {
        [compcopy removeObjectAtIndex:0];
        args = [NSArray arrayWithArray:compcopy];
    }
    
    desc = [NSMutableString descBbObject:className
                               ancestors:ancestors+1
                                position:@[@(p.normalizedPosition.x),@(p.normalizedPosition.y)]
                                    args:args
            ];
    
    return desc;
}

- (void)swapPlaceholderView:(BbCocoaPlaceholderObjectView *)placeholderView
  withObjectCreatedFromText:(NSString *)text
{
#if TARGET_OS_IPHONE
    [placeholderView removeFromSuperview];
#else
    [placeholderView removeFromSuperviewWithoutNeedingDisplay];

#endif
    [self addObjectWithText:text];
}

- (BbViewType)viewType
{
    return BbViewType_Patch;
}


@end
