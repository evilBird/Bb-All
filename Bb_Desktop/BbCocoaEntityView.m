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
}

- (void)commonInitDescription:(id)viewDescription
{
    kSelected = NO;
}

- (void)setupConstraints
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
}
- (void)setupConstraintsParent:(id)parent
{
    if (parent) {
        return;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [(NSView *)parent addSubview:self];
    
}

/*
- (void)setParentView:(BbCocoaEntityView *)parentView
{
    _parentView = parentView;
    [_parentView addSubview:self];
    [self setupConstraints];
    [self refreshEntityView];
}
*/


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

- (void)setCenter:(CGPoint)center
{
    /*
    CGRect oldFrame = self.frame;
    CGPoint oldCenter = [NSView centerForFrame:oldFrame];
    CGFloat dx = center.x - oldCenter.x;
    CGFloat dy = center.y - oldCenter.y;
    CGRect newFrame = CGRectOffset(self.frame, dx, dy);
    self.frame = newFrame;
    [self refreshEntityView];
     */
}

- (void)setCenter:(CGPoint)center inView:(id<BbEntityView>)view
{
    /*
    NSView *toCenter = (NSView *)view;
    NSView *selfView = (NSView *)self;
    CGRect frame = [selfView convertRect:toCenter.bounds fromView:toCenter];
    CGPoint oldCenter = [NSView centerForFrame:frame];
    CGFloat dx = oldCenter.x - center.x;
    CGFloat dy = oldCenter.y - center.y;
    CGRect newFrame = CGRectOffset(toCenter.frame, dx, dy);
    toCenter.frame = newFrame;
    [view refreshEntityView];
     */
}

- (CGPoint)center
{
    return [NSView centerForFrame:self.frame];
}

- (void)addSubview:(id<BbEntityView>)subview
{
    [super addSubview:(NSView *)subview];
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

- (instancetype)initWithDescription:(id)viewDescription
                           inParent:(id)parentView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        [self commonInitDescription:viewDescription];
        [self setupConstraintsParent:parentView];
        [self refreshEntityView];
    }
    
    return self;
}

- (instancetype)initWithDescription:(id)viewDescription
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
     
        [self commonInitDescription:viewDescription];
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
