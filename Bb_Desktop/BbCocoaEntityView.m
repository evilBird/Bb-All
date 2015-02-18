//
//  BbCocoaEntityView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView.h"
#import "BbBase.h"
#import "BbCocoaObjectView.h"

@interface BbCocoaEntityView ()

@end

@implementation BbCocoaEntityView

#pragma mark - Public Methods

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    self.selected = NO;
    kMinWidth = kDefaultMinWidth;
    self.entity = entity;
    self.viewDescription = viewDescription;
}

- (void)setupConstraintsInParentView:(id)parent
{
    if (!parent) {
        return;
    }
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [(NSView *)parent addSubview:self];
}


#pragma mark - Overrides

- (void)setEntity:(BbEntity *)entity
{
    _entity = entity;
    _entity.view = self;
}

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
    kCenter = center;
}
- (CGPoint)center
{
    return [NSView centerForFrame:self.frame];
}

- (void)setEditing:(BOOL)editing
{
    if (editing != _editing) {
        _editing = editing;
        [self setNeedsDisplay:YES];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (selected != _selected) {
        _selected = selected;
        
        [self setNeedsDisplay:YES];
    }
}

- (void)addSubview:(id<BbEntityView>)subview
{
    [super addSubview:(NSView *)subview];
}

- (void)refresh
{
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        [self setNeedsLayout:YES];
    }
    
    [self setNeedsDisplay:YES];
    
}

#pragma constructors

- (instancetype)initWithEntity:(id)entity
               viewDescription:(id)viewDescription
                      inParent:(id)parentView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self commonInitEntity:entity viewDescription:viewDescription];
        [self setupConstraintsInParentView:parentView];
        [self refresh];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSColor *fillColor;
    if (self.selected || self.editing) {
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
