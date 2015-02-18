//
//  BbCocoaHSliderView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/12/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaHSliderView.h"
#import "BbCocoaPortView.h"

@implementation BbCocoaHSliderView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    self.slider = [[NSSlider alloc]init];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.minValue = 0.0;
    self.slider.maxValue = 1.0;
    [self.slider setDoubleValue:0.5];
    self.slider.continuous = YES;
    [(NSView *)self addSubview:self.slider];
    [self.slider setTarget:entity];
    SEL selector = NSSelectorFromString(@"sliderValueDidChange:");
    [self.slider setAction:selector];
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self.slider autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(kPortViewWidthConstraint + 2)];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPortViewWidthConstraint/2];
}

- (NSSize)intrinsicContentSize
{
    CGFloat width = kDefaultCocoaObjectViewWidth * 2.5;
    CGFloat height = kDefaultCocoaObjectViewHeight/1.5;
    CGSize size;
    size.width = width;
    size.height = height;
    return NSSizeFromCGSize(size);
}

- (NSColor *)defaultColor
{
    return [NSColor colorWithWhite:0.92 alpha:1];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.8 alpha:1];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    NSColor *fillColor;
    if (self.selected) {
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRect:self.bounds];
    [outlinePath setLineWidth:1];
    [[NSColor colorWithWhite:0.5 alpha:1]setStroke];
    [outlinePath stroke];
}

@end
