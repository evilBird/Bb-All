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

@implementation BbCocoaObjectView (Autolayout)

- (void)setWidth:(CGFloat)width height:(CGFloat)height
{
    NSArray *constraints = nil;
    NSDictionary *views = NSDictionaryOfVariableBindings(self);
    NSDictionary *metrics = @{@"width":@(width),
                              @"height":@(height)
                              };
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"V:[self(==height)]"
                   options:0
                   metrics:metrics
                   views:views];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:[self(==width)]"
                   options:0
                   metrics:metrics
                   views:views];
    [self addConstraints:constraints];
}


- (void)layoutPortviews:(NSArray *)portViews spacers:(NSArray *)spacers isTopRow:(BOOL)isTopRow
{
    if (!portViews) {
        return;
    }
    
    NSUInteger i = 0;

    
    for (BbCocoaPortView *portView in portViews){
        
        if (portView) {
            portView.parentView = self;
            NSArray *constraints = nil;
            NSDictionary *views = NSDictionaryOfVariableBindings(portView);
            NSDictionary *metrics = @{@"width":@(kPortViewWidthConstraint),
                                      @"height":@(kPortViewHeightConstraint)
                                      };
            constraints = [NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:[portView(==width)]"
                           options:0
                           metrics:metrics
                           views:views];
            [self addConstraints:constraints];
            
            constraints = [NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:[portView(==height)]"
                           options:0
                           metrics:metrics
                           views:views];
            [self addConstraints:constraints];
        }

        NSView *previousSpacer = nil;
        NSView *nextSpacer = nil;
        if (i>0){
            previousSpacer = spacers[(i-1)];
        }
        if (i<spacers.count){
            nextSpacer = spacers[i];
            if (nextSpacer) {
                [self addSubview:(id<BbEntityView>)nextSpacer];
                NSArray *constraints = nil;
                NSDictionary *views = NSDictionaryOfVariableBindings(nextSpacer);
                NSDictionary *metrics = @{@"minSize":@(kMinHorizontalSpacerSize)};
                
                constraints = [NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[nextSpacer(>=minSize)]"
                               options:0
                               metrics:metrics
                               views:views];
                [nextSpacer addConstraints:constraints];
            }
        }
        
        NSLayoutConstraint *constraint = nil;
        
        NSLayoutAttribute verticalAttribute;
        CGFloat offset = 0.0;
        if (isTopRow){
            verticalAttribute = NSLayoutAttributeTop;
            offset = 1.0f;
        }else{
            verticalAttribute = NSLayoutAttributeBottom;
            offset = -1.0f;
        }
        
        constraint = [NSLayoutConstraint
                      constraintWithItem:portView
                      attribute:verticalAttribute
                      relatedBy:NSLayoutRelationEqual
                      toItem:self
                      attribute:verticalAttribute
                      multiplier:1.0
                      constant:offset];
        [self addConstraint:constraint];
        
        if (portView && nextSpacer && !previousSpacer) {
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:portView
                          attribute:NSLayoutAttributeLeft
                          relatedBy:NSLayoutRelationEqual
                          toItem:self
                          attribute:NSLayoutAttributeLeft
                          multiplier:1.0
                          constant:1];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeTop
                          relatedBy:NSLayoutRelationEqual
                          toItem:portView
                          attribute:NSLayoutAttributeTop
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeBottom
                          relatedBy:NSLayoutRelationEqual
                          toItem:portView
                          attribute:NSLayoutAttributeBottom
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            if (portViews.count == spacers.count == 1) {
                constraint = [NSLayoutConstraint
                              constraintWithItem:nextSpacer
                              attribute:NSLayoutAttributeRight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self
                              attribute:NSLayoutAttributeRight
                              multiplier:1.0
                              constant:-1.0];
                [self addConstraint:constraint];
            }
            
        }else if (portView && nextSpacer && previousSpacer){
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:portView
                          attribute:NSLayoutAttributeLeft
                          relatedBy:NSLayoutRelationEqual
                          toItem:previousSpacer
                          attribute:NSLayoutAttributeRight
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeWidth
                          relatedBy:NSLayoutRelationGreaterThanOrEqual
                          toItem:portView
                          attribute:NSLayoutAttributeWidth
                          multiplier:0.0
                          constant:kMinHorizontalSpacerSize];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeTop
                          relatedBy:NSLayoutRelationEqual
                          toItem:portView
                          attribute:NSLayoutAttributeTop
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeBottom
                          relatedBy:NSLayoutRelationEqual
                          toItem:portView
                          attribute:NSLayoutAttributeBottom
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:nextSpacer
                          attribute:NSLayoutAttributeWidth
                          relatedBy:NSLayoutRelationEqual
                          toItem:previousSpacer
                          attribute:NSLayoutAttributeWidth
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
        }else if (portView && previousSpacer && !nextSpacer){
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:portView
                          attribute:NSLayoutAttributeLeft
                          relatedBy:NSLayoutRelationEqual
                          toItem:previousSpacer
                          attribute:NSLayoutAttributeRight
                          multiplier:1.0
                          constant:0.0];
            [self addConstraint:constraint];
            
            constraint = [NSLayoutConstraint
                          constraintWithItem:portView
                          attribute:NSLayoutAttributeRight
                          relatedBy:NSLayoutRelationEqual
                          toItem:self
                          attribute:NSLayoutAttributeRight
                          multiplier:1.0
                          constant:-1.0];
            [self addConstraint:constraint];
            
        }else{
            NSLog(@"oops didn't catch it");
        }
        
        i++;
    }
    
}

- (NSArray *)spacerViewsForPortViews:(NSArray *)portViews
{
    if (!portViews || portViews.count == 0) {
        return nil;
    }
    
    NSUInteger spacerCount;
    if (portViews.count == 1){
        spacerCount = 1;
    }else{
        spacerCount = portViews.count - 1;
    }
    
    NSMutableArray *spacerViews = [NSMutableArray arrayWithCapacity:spacerCount];
    for (NSUInteger i = 0; i<spacerCount;i++){
        NSView *spacerView = [NSView new];
        spacerView.translatesAutoresizingMaskIntoConstraints = NO;
        if (spacerView != nil){
            [spacerViews addObject:spacerView];
        }
    }
    
    return spacerViews;
}

- (NSArray *)portViewsWithCount:(NSUInteger)count
{
    if (count == 0) {
        return nil;
    }
    
    NSMutableArray *portViews = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i<count;i++)
    {
        BbCocoaPortView *portView = [BbCocoaPortView new];
        if (portView != nil){
            [portViews addObject:portView];
        }
    }
    
    return portViews;
}

- (void)setCenterPoint:(CGPoint)centerPoint
{
    
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

+ (NSSize)spacerSizeForConfig:(BbObjectViewConfiguration *)config
{
    CGFloat logicalSpacerWidthTop,logicalSpacerWidthBottom = 0.0;
    
    if (config.inlets > 1) {
        logicalSpacerWidthTop = config.inlets * kPortViewWidthConstraint;
    }
    if (config.outlets > 1) {
        logicalSpacerWidthBottom = config.inlets * kPortViewWidthConstraint;
    }
    
    CGFloat logicalSpacerWidth = 0.0;
    if (logicalSpacerWidthBottom > logicalSpacerWidthTop) {
        logicalSpacerWidth = logicalSpacerWidthBottom;
    }else if (logicalSpacerWidthTop > logicalSpacerWidthBottom){
        logicalSpacerWidth = logicalSpacerWidthTop;
    }
    
    CGFloat finalSpacerWidth = 0.0f;
    if (logicalSpacerWidth>kMinHorizontalSpacerSize) {
        finalSpacerWidth = logicalSpacerWidth;
    }else{
        finalSpacerWidth = kMinHorizontalSpacerSize;
    }
    
    NSSize result = NSMakeSize(finalSpacerWidth, kPortViewHeightConstraint);
    return result;
}

+ (NSSize)portSize
{
    return NSSizeFromCGSize(CGSizeMake(kPortViewWidthConstraint, kPortViewHeightConstraint));
}

+ (NSSize)frameSizeForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text
{
    NSSize result;
    result.width = [BbCocoaObjectView widthForInlets:inlets outlets:outlets text:text];
    result.height = (kPortViewWidthConstraint * 2.0) + kMinVerticalSpacerSize + 2;
    return result;
}

+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets
{
    CGFloat topWidth = [BbCocoaObjectView widthForPortCount:inlets] + 2;
    CGFloat bottomWidth = [BbCocoaObjectView widthForPortCount:outlets] + 2;
    if (topWidth>=bottomWidth) {
        return topWidth;
    }else{
        return bottomWidth;
    }
}

+ (CGFloat)widthForInlets:(NSUInteger)inlets outlets:(NSUInteger)outlets text:(NSString *)text
{
    CGFloat portBasedWidth = [BbCocoaObjectView widthForInlets:inlets outlets:outlets];
    CGSize textBasedSize = [text sizeWithAttributes:[BbObjectViewConfiguration textAttributes]];
    CGFloat textBasedWidth = [BbCocoaObjectView roundFloat:(textBasedSize.width + kPortViewWidthConstraint + 2)];
    
    if (portBasedWidth > textBasedWidth) {
        return portBasedWidth;
    }else{
        return textBasedWidth;
    }
}

+ (CGFloat)widthForPortCount:(NSUInteger)portCount
{
    if (portCount == 0) {
        return 0;
    }
    return (CGFloat)portCount * kPortViewWidthConstraint + ((CGFloat)(portCount - 1) * kPortViewWidthConstraint);
}

+ (CGFloat)roundFloat:(CGFloat)aFloat
{
    return (CGFloat)(NSInteger)(aFloat + 0.5);
}

@end
