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
    self.slider = [[VCSlider alloc]init];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    #if TARGET_OS_IPHONE == 1
    
#else
    self.slider.minValue = 0.0;
    self.slider.maxValue = 1.0;
    [self.slider setDoubleValue:0.5];
    [self.slider setTarget:entity];
    SEL selector = NSSelectorFromString(@"sliderValueDidChange:");
    [self.slider setAction:selector];
#endif

    self.slider.continuous = YES;
    [(VCView *)self addSubview:self.slider];

}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self.slider autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:(kPortViewWidthConstraint + 2)];
    [self.slider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPortViewWidthConstraint/2];
}

- (VCSize)intrinsicContentSize
{
    CGFloat width = kDefaultCocoaObjectViewWidth * 2.5;
    CGFloat height = kDefaultCocoaObjectViewHeight/1.5;
    VCSize size;
    size.width = width;
    size.height = height;
    return size;
}

- (VCColor *)defaultColor
{
    return [VCColor colorWithWhite:0.92 alpha:1];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.8 alpha:1];
}

- (void)drawRect:(VCRect)dirtyRect {
    // Drawing code here.
    VCColor *fillColor;
    if (self.selected) {
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
#if TARGET_OS_IPHONE == 1
    //TODO
#else
    NSRectFill(dirtyRect);
#endif
    
    VCBezierPath *outlinePath = [VCBezierPath bezierPathWithRect:self.bounds];
    [outlinePath setLineWidth:1];
    [[VCColor colorWithWhite:0.5 alpha:1]setStroke];
    [outlinePath stroke];
}

@end
