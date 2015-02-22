//
//  BbCocoaObjectView+Autolayout.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaObjectView+Autolayout.h"
#import "BbCocoaPortView.h"
#import "NSView+Bb.h"
#import "PureLayout.h"
#import "BbPorts.h"

@implementation BbCocoaObjectView (Autolayout)

- (CGFloat)horizontalSpacerObjectViewWidth:(CGFloat)objectViewWidth
                             portViewWidth:(CGFloat)portViewWidth
                             portViewCount:(NSUInteger)portViewCount
                            minSpacerWidth:(CGFloat)minSpacerWidth
{
    NSUInteger numSpacers = [self numberOfSpacersForPortViewCount:portViewCount];
    CGFloat totalWidthForPortViews = portViewWidth * (CGFloat)portViewCount;
    CGFloat totalWidthForSpacers = objectViewWidth - totalWidthForPortViews;
    CGFloat logicalSpacerWidth = totalWidthForSpacers/(CGFloat)numSpacers;
    CGFloat result = [self maxOfValue1:logicalSpacerWidth value2:minSpacerWidth];
    return [self roundFloat:result];
}

- (CGFloat)intrinsicWidthForObjectWithInlets:(NSUInteger)inlets
                                     outlets:(NSUInteger)outlets
                               portViewWidth:(CGFloat)portViewWidth
                               displayedText:(NSString *)displayedText
                     displayedTextAttributes:(NSDictionary *)displayedTextAttributes
                         textExpansionFactor:(CGFloat)textExpansion
                              minPortSpacing:(CGFloat)minPortSpacing
                                defaultWidth:(CGFloat)defaultWidth
{
    CGFloat widthRequiredByPorts,widthRequiredByText,requiredWidth,result;
    CGFloat totalWidthForInlets = (CGFloat)inlets * portViewWidth;
    NSUInteger inletSpacers = [self numberOfSpacersForPortViewCount:inlets];
    CGFloat widthForInletSpacers = (CGFloat)inletSpacers * minPortSpacing;
    CGFloat requiredTopWidth = totalWidthForInlets + widthForInletSpacers;
    
    CGFloat totalWidthForOutlets = (CGFloat)outlets * portViewWidth;
    NSUInteger outletSpacers = [self numberOfSpacersForPortViewCount:outlets];
    CGFloat widthForOutletSpacers = (CGFloat)outletSpacers * minPortSpacing;
    CGFloat requiredBottomWidth = totalWidthForOutlets + widthForOutletSpacers;
    widthRequiredByPorts = [self maxOfValue1:requiredTopWidth value2:requiredBottomWidth];
    
    if (inlets == outlets == 1) {
        widthRequiredByPorts = defaultWidth;
    }
    
    CGFloat textWidthRaw = [displayedText sizeWithAttributes:displayedTextAttributes].width;
    CGFloat textWidth = pow(textWidthRaw, textExpansion);
    CGFloat textInsetsWidth = portViewWidth;
    widthRequiredByText = textWidth + textInsetsWidth;
    requiredWidth = [self maxOfValue1:widthRequiredByPorts value2:widthRequiredByText];
    result = requiredWidth;
    
    return [self roundFloat:result];
}

- (CGFloat)intrinsicWidthForObjectWithInlets:(NSUInteger)inlets
                                     outlets:(NSUInteger)outlets
                               portViewWidth:(CGFloat)portViewWidth
                               displayedText:(NSString *)displayedText
                     displayedTextAttributes:(NSDictionary *)displayedTextAttributes
                              minPortSpacing:(CGFloat)minPortSpacing
                                defaultWidth:(CGFloat)defaultWidth
{
    return [self intrinsicWidthForObjectWithInlets:inlets
                                           outlets:outlets
                                     portViewWidth:portViewWidth
                                     displayedText:displayedText
                           displayedTextAttributes:displayedTextAttributes
                               textExpansionFactor:1.0
                                    minPortSpacing:minPortSpacing
                                      defaultWidth:defaultWidth];
}


- (NSUInteger)numberOfSpacersForPortViewCount:(NSUInteger)portViewCount
{
    if (portViewCount <=1) {
        return 0;
    }
    
    return portViewCount - 1;
}


- (CGFloat)maxOfValue1:(CGFloat)value1 value2:(CGFloat)value2
{
    if (value1 >= value2) {
        return value1;
    }
    
    return value2;
}

- (CGFloat)minOfValue1:(CGFloat)value1 value2:(CGFloat)value2
{
    if (value1 <= value2) {
        return value1;
    }
    
    return value2;
}

- (void)layoutInletViews:(NSArray *)inletViews
{
    if (!inletViews) {
        return;
    }
    
    BbCocoaPortView *inletView = inletViews.firstObject;
    [inletView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [inletView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    
    if (inletViews.count > 1){
        CGFloat myWidth = [self intrinsicContentSize].width;
        CGFloat spacerSize = [self horizontalSpacerObjectViewWidth:myWidth
                                                     portViewWidth:kPortViewWidthConstraint
                                                     portViewCount:inletViews.count
                                                    minSpacerWidth:kMinHorizontalSpacerSize];
        
        [inletViews autoDistributeViewsAlongAxis:ALAxisHorizontal
                                       alignedTo:ALAttributeTop
                                withFixedSpacing:spacerSize
                                    insetSpacing:NO];
    }
}

- (void)layoutOutletViews:(NSArray *)outletViews
{
    if (!outletViews) {
        return;
    }
    
    BbCocoaPortView *outletView = outletViews.firstObject;
    [outletView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [outletView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    
    if (outletViews.count > 1) {
        CGFloat myWidth = [self intrinsicContentSize].width;
        CGFloat spacerSize = [self horizontalSpacerObjectViewWidth:myWidth
                                                     portViewWidth:kPortViewWidthConstraint
                                                     portViewCount:outletViews.count
                                                    minSpacerWidth:kMinHorizontalSpacerSize];
        
        [outletViews autoDistributeViewsAlongAxis:ALAxisHorizontal
                                        alignedTo:ALAttributeBottom
                                 withFixedSpacing:spacerSize
                                     insetSpacing:NO];
    }
}

- (NSArray *)addViewsForBbPortEntities:(NSArray *)portEntities
{
    if (!portEntities || portEntities.count == 0) {
        return nil;
    }
    NSMutableArray *portViews = nil;
    for (BbPort *port in portEntities) {
        BbCocoaPortView *portView = [[BbCocoaPortView alloc]initWithEntity:port
                                                           viewDescription:nil
                                                                  inParent:self];
        //[portView setNeedsLayout:YES];
        if (!portViews) {
            portViews = [NSMutableArray arrayWithCapacity:portEntities.count];
        }
        
        [portViews addObject:portView];
    }
    
    return portViews;
}

- (void)setHorizontalCenter:(CGFloat)horizontalCenter
{
    self.centerXConstraint = [self horizontalCenterConstraint:horizontalCenter];
}

- (void)setVerticalCenter:(CGFloat)verticalCenter
{
    self.centerYConstraint = [self verticalCenterConstraint:verticalCenter];
}

+ (NSPoint)position:(NSPoint)position forView:(NSView *)view inSuperview:(NSView *)superview
{
    return [view convertPoint:position fromView:superview];
}

- (CGFloat)roundFloat:(CGFloat)aFloat
{
    return (CGFloat)(NSInteger)(aFloat + 0.5);
}

@end
