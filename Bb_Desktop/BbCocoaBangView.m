//
//  BbCocoaBangView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaBangView.h"
#import "BbBangObject.h"

@implementation BbCocoaBangView

- (NSColor *)defaultColor
{
    return [NSColor colorWithWhite:0.85 alpha:1];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.7 alpha:1];
}

- (NSColor *)backgroundFillColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}

- (NSColor *)editingFillColor
{
    return [NSColor colorWithWhite:0.8 alpha:1];
}

- (NSSize)intrinsicContentSize
{
    return NSSizeFromCGSize(CGSizeMake(kDefaultBangViewSize, kDefaultBangViewSize));
}

- (id)clickDown:(NSEvent *)theEvent
{
    self.editing = YES;
    [self setSelected:YES];
    [self setNeedsDisplay:YES];
    return self;
}

- (id)clickUp:(NSEvent *)theEvent
{
    [self setSelected:NO];
    [self setNeedsDisplay:YES];
    switch (theEvent.clickCount) {
        case 1:
            if (self.editing) {
                [self setEditing:NO];
                [self setNeedsDisplay:YES];
                return nil;
            }else{
                [self setEditing:YES];
                [self setNeedsDisplay:YES];
                return self;
            }
            break;
        default:
            [self setEditing:NO];
            [self setNeedsDisplay:YES];
            return nil;
            break;
    }
}

- (void)setSelected:(BOOL)selected
{
    if (selected != kSelected)
    {
        kSelected = selected;
        if (kSelected) {
            [[(BbBangObject *)self.entity hotInlet]input:[BbBang bang]];
        }
    }

}
- (void)drawRect:(NSRect)dirtyRect {

    NSColor *backgroundColor = nil;
    if (self.editing) {
        backgroundColor = [self backgroundFillColor];
    }else{
        backgroundColor = [self editingFillColor];
    }
    
    [backgroundColor setFill];
    
    NSRectFill(dirtyRect);
    // Drawing code here.
    
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithOvalInRect:NSRectFromCGRect(CGRectInset(self.bounds, 4, 4))];
    NSColor *fillColor = nil;
    if (kSelected) {
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    [[NSColor blackColor]setStroke];
    [bezierPath setLineWidth:1];
    [bezierPath fill];
    [bezierPath stroke];
    
    NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRect:self.bounds];
    [outlinePath stroke];
}

@end
