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
#import "BbCocoaEntityView+TextDelegate.h"


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
    
    [self addObserver:self
           forKeyPath:@"selected"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self addObserver:self
           forKeyPath:@"editing"
              options:NSKeyValueObservingOptionNew
              context:nil];
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

- (NSColor *)editingColor
{
    return [NSColor colorWithRed:97.0/255.0 green:90.0/255.0f blue:11.0f/255.0f alpha:1];
}

- (CGFloat)textExpansionFactor
{
    if (self.editing) {
        return [self editingTextExpansionFactor];
    }else{
        return [self defaultTextExpansionFactor];
    }
}

- (CGFloat)editingTextExpansionFactor
{
    return 1.1;
}
- (CGFloat)defaultTextExpansionFactor
{
    return 1.0;
}

- (NSColor *)blendColor:(NSColor *)color1 weight:(CGFloat)weight1 withColor:(NSColor *)color2 weight:(CGFloat)weight2
{
    CGFloat sumOfWeights = weight1+weight2;
    CGFloat normWeight1 = weight1/sumOfWeights;
    CGFloat normWeight2 = weight2/sumOfWeights;
    CGFloat new[4];
    for (NSUInteger i = 0; i < 4; i++) {
        CGFloat c1 = CGColorGetComponents(color1.CGColor)[i];
        CGFloat c2 = CGColorGetComponents(color2.CGColor)[i];
        CGFloat c3 = (c1 * normWeight1) + (c2 * normWeight2);
        new[i] = c3;
    }
    
    return [NSColor colorWithRed:new[0] green:new[1] blue:new[2] alpha:new[3]];
}

#pragma mark BbEntityView Methods

- (void)setSelected:(BOOL)selected
{
    if (selected != _selected) {
        _selected = selected;
    }
}

- (void)setEditing:(BOOL)editing
{
    if (editing != _editing) {
        _editing = editing;
    }
}

- (void)setCenter:(CGPoint)center
{
    kCenter = center;
}

- (CGPoint)center
{
    return [NSView centerForFrame:self.frame];
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        NSNumber *changeValue = change[@"new"];
        BOOL newValue = changeValue.boolValue;
        if ([keyPath isEqualToString:@"selected"])
        {
            if (newValue) {
                [self entityViewDidBeginSelected:self];
            }else{
                [self entityViewDidEndSelected:self];
            }
        }
        else if ([keyPath isEqualToString:@"editing"])
        {
            if (newValue) {
                [self entityView:self didBeginEditingObject:self.textField];
            }else{
                [self entityView:self didEndEditingObject:self.textField];
            }
        }
        
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)entityView:(id)sender didBeginEditingObject:(id)object
{
    if (sender == self && object == self.textField){
        [self beginEditingText];
    }
}

- (void)entityView:(id)sender didEndEditingObject:(id)object
{
    if (sender == self && object == self.textField){
        [self endEditingText];
    }
}

- (void)entityViewDidBeginSelected:(id)sender {}
- (void)entityViewDidEndSelected:(id)sender {}

- (id)selectionObject
{
    return self.textField;
}

- (id)editingObject
{
    return self.textField;
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
    if (self.editing) {
        fillColor = self.editingColor;
    }else if (self.selected){
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selected"];
    [self removeObserver:self forKeyPath:@"editing"];
}

@end
