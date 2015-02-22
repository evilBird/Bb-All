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

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
}

- (NSColor *)defaultColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.8 alpha:1];
}

- (NSColor *)sendingColor
{
    return [NSColor colorWithWhite:0.5 alpha:1];
}

- (NSColor *)notSendingColor
{
    return [NSColor colorWithWhite:0.75 alpha:1];
}

- (NSSize)intrinsicContentSize
{
    return NSSizeFromCGSize(CGSizeMake(kDefaultBangViewSize, kDefaultBangViewSize));
}

- (void)sendBang
{
    [[(BbBangObject *)self.entity hotInlet]input:[BbBang bang]];
    self.sending = YES;
    [self setNeedsDisplay:YES];
    
    __weak BbCocoaBangView *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself endBang];
    });
}

- (void)endBang
{
    self.sending = NO;
    [self setNeedsDisplay:YES];
}

- (NSRect)hitTestRect
{
    return (CGRectInset(self.bounds, 16, 16));
}

- (NSRect)insetRect
{
    return (CGRectInset(self.bounds, 4, 4));
}

- (id)clickDown:(NSEvent *)theEvent
{
    CGPoint thePoint = [self convertPoint:theEvent.locationInWindow fromView:self.superview];
    CGRect bangRect = [self hitTestRect];
    if (CGRectContainsPoint(bangRect, thePoint)) {
        [self sendBang];
        if (self.selected) {
            return self;
        }else{
            return nil;
        }
    }
    
    if (theEvent.clickCount == 1) {
        if (self.selected) {
            self.selected = NO;
            return nil;
        }else{
            self.selected = YES;
            return self;
        }
    }else{
        self.selected = NO;
        return nil;
    }
    
    return nil;
}


- (void)drawRect:(NSRect)dirtyRect {

    NSColor *backgroundColor = nil;
    
    if (self.selected) {
        backgroundColor = self.selectedColor;
    }else{
        backgroundColor = self.defaultColor;
    }
    
    [backgroundColor setFill];
    
    NSRectFill(dirtyRect);
    // Drawing code here.
    
    NSRect insetRect = [self insetRect];
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithOvalInRect:insetRect];
    NSColor *fillColor = nil;
    
    if (self.sending) {
        fillColor = [self sendingColor];
    }else{
        fillColor = [self notSendingColor];
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
