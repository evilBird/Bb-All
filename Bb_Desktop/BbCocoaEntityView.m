//
//  BbCocoaEntityView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"

@interface BbCocoaEntityView ()

@end

@implementation BbCocoaEntityView

#pragma mark - Public Methods

- (void)commonInit
{
    kSelected = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints {}


- (void)setParentView:(BbCocoaEntityView *)parentView
{
    _parentView = parentView;
    [_parentView addSubview:self];
    [self setupConstraints];
    [self refreshEntityView];
}

#pragma mark - Overrides
- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1];
}

#pragma mark BbEntityView Methods

- (CGRect)frame
{
    return [super frame];
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void)setCenter:(CGPoint)center
{
    CGRect oldFrame = self.frame;
    CGPoint oldCenter = [NSView centerForFrame:oldFrame];
    CGFloat dx = center.x - oldCenter.x;
    CGFloat dy = center.y - oldCenter.y;
    CGRect newFrame = CGRectOffset(self.frame, dx, dy);
    self.frame = newFrame;
    [self refreshEntityView];
}

- (void)setCenter:(CGPoint)center inView:(id<BbEntityView>)view
{
    NSView *toCenter = (NSView *)view;
    NSView *selfView = (NSView *)self;
    CGRect frame = [selfView convertRect:toCenter.bounds fromView:toCenter];
    CGPoint oldCenter = [NSView centerForFrame:frame];
    CGFloat dx = oldCenter.x - center.x;
    CGFloat dy = oldCenter.y - center.y;
    CGRect newFrame = CGRectOffset(toCenter.frame, dx, dy);
    toCenter.frame = newFrame;
    [view refreshEntityView];
}

- (CGPoint)center
{
    return [NSView centerForFrame:self.frame];
}

- (void)addSubview:(id<BbEntityView>)subview
{
    [super addSubview:(NSView *)subview];
}
- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (BOOL)selected
{
    return kSelected;
}

- (void)setSelected:(BOOL)selected
{
    if (selected != kSelected) {
        kSelected = selected;
        [self refreshEntityView];
    }
}

- (void)refreshEntityView
{
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
}

#pragma constructors
- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];;
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSColor *fillColor;
    if (kSelected) {
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
