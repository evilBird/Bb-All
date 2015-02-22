//
//  BbCocoaObjectView+Autolayout.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaObjectView.h"

@interface BbCocoaObjectView (Autolayout)

- (NSArray *)addViewsForBbPortEntities:(NSArray *)portEntities;

- (void)layoutInletViews:(NSArray *)inletViews;
- (void)layoutOutletViews:(NSArray *)outletViews;

- (CGFloat)horizontalSpacerObjectViewWidth:(CGFloat)objectViewWidth
                             portViewWidth:(CGFloat)portViewWidth
                             portViewCount:(NSUInteger)portViewCount
                            minSpacerWidth:(CGFloat)minSpacerWidth;

- (CGFloat)intrinsicWidthForObjectWithInlets:(NSUInteger)inlets
                                      outlets:(NSUInteger)outlets
                               portViewWidth:(CGFloat)portViewWidth
                               displayedText:(NSString *)displayedText
                     displayedTextAttributes:(NSDictionary *)displayedTextAttributes
                              minPortSpacing:(CGFloat)minPortSpacing
                                defaultWidth:(CGFloat)defaultWidth;

- (CGFloat)intrinsicWidthForObjectWithInlets:(NSUInteger)inlets
                                     outlets:(NSUInteger)outlets
                               portViewWidth:(CGFloat)portViewWidth
                               displayedText:(NSString *)displayedText
                     displayedTextAttributes:(NSDictionary *)displayedTextAttributes
                         textExpansionFactor:(CGFloat)textExpansion
                              minPortSpacing:(CGFloat)minPortSpacing
                                defaultWidth:(CGFloat)defaultWidth;



- (void)setHorizontalCenter:(CGFloat)horizontalCenter;
- (void)setVerticalCenter:(CGFloat)verticalCenter;
+ (NSPoint)position:(NSPoint)position forView:(NSView *)view inSuperview:(NSView *)superview;
- (CGFloat)roundFloat:(CGFloat)aFloat;


@end
