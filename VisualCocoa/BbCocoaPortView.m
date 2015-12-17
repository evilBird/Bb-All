//
//  BbCocoaPortView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPortView.h"
#import "BbObject.h"
#import "NSString+Bb.h"
#import "BbCocoaPatchView.h"

#if TARGET_OS_IPHONE
#import "UIView+Bb.h"
#else
#import "NSView+Bb.h"
#endif

@interface BbCocoaPortView ()

@end

@implementation BbCocoaPortView

#pragma mark - Public Methods

- (VCPoint)center
{
    BbEntity *port = self.entity;
    BbEntity *parent =  port.parent;
    BbEntity *grandParent = parent.parent;
    if (!grandParent) {
        return [VCView centerForFrame:self.frame];
    }else{
        VCRect p_frame = [(VCView *)[parent view] convertRect:self.bounds fromView:self];
        VCRect gp_frame = [(VCView *)[grandParent view] convertRect:p_frame fromView:(VCView *)[parent view]];
        return [VCView centerForFrame:gp_frame];
    }
}

- (VCSize)intrinsicContentSize
{
    VCSize size;
    size.width = kPortViewWidthConstraint;
    size.height = kPortViewHeightConstraint;
    return size;
}


#pragma mark - Overrides
- (VCColor *)defaultColor
{
    return [VCColor whiteColor];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.7 alpha:1];
}

- (void)drawRect:(VCRect)dirtyRect {
    [super drawRect:dirtyRect];
    VCBezierPath *outlinePath = [VCBezierPath bezierPathWithRect:self.bounds];
    [outlinePath setLineWidth:1.0];
    [[VCColor blackColor]setStroke];
    [outlinePath stroke];
}

- (id)clickDown:(VCEvent *)theEvent
{
    if ([self.entity isKindOfClass:[BbInlet class]]) {
        return nil;
    }else{
        [self setSelected:YES];
        
#if TARGET_OS_IPHONE == 1
        [self setNeedsDisplay];
        
#else
        [self setNeedsDisplay:YES];
#endif
        
        return self;
    }
}

- (id)clickUp:(VCEvent *)theEvent
{
    [self setSelected:NO];
#if TARGET_OS_IPHONE == 1
    [self setNeedsDisplay];
    
#else
    [self setNeedsDisplay:YES];
#endif
    return nil;
}

- (id)boundsWereEntered:(VCEvent *)theEvent
{
    if (![self.entity isKindOfClass:[BbInlet class]]) {
        return nil;
    }
    
    [self setSelected:YES];
    
    #if TARGET_OS_IPHONE == 1
        [self setNeedsDisplay];
        
#else
        [self setNeedsDisplay:YES];
#endif
    
    return self;
}

- (id)boundsWereExited:(VCEvent *)theEvent
{
    [self setSelected:NO];
    #if TARGET_OS_IPHONE == 1
        [self setNeedsDisplay];
        
#else
        [self setNeedsDisplay:YES];
#endif
    
    return nil;
}

- (BbViewType)viewType
{
    return BbViewType_Port;
}

@end
