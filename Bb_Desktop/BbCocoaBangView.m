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

- (NSSize)intrinsicContentSize
{
    return NSSizeFromCGSize(CGSizeMake(kDefaultBangViewSize, kDefaultBangViewSize));
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [[(BbBangObject *)self.entity hotInlet]input:[BbBang bang]];
    }
}
- (void)drawRect:(NSRect)dirtyRect {

    [[self backgroundFillColor] setFill];
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
