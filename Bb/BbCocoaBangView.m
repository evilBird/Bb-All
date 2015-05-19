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

- (VCColor *)defaultColor
{
    return [VCColor colorWithWhite:0.9 alpha:1];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.8 alpha:1];
}

- (VCColor *)sendingColor
{
    return [VCColor colorWithWhite:0.5 alpha:1];
}

- (VCColor *)notSendingColor
{
    return [VCColor colorWithWhite:0.75 alpha:1];
}

- (VCSize)intrinsicContentSize
{
    return CGSizeMake(kDefaultBangViewSize, kDefaultBangViewSize);
}

- (void)sendBang
{
    [[(BbBangObject *)self.entity hotInlet]input:[BbBang bang]];
    self.sending = YES;
#if TARGET_OS_IPHONE == 1
        [self setNeedsDisplay];
        
#else
        [self setNeedsDisplay:YES];
#endif
    
    __weak BbCocoaBangView *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself endBang];
    });
}

- (void)endBang
{
    self.sending = NO;
#if TARGET_OS_IPHONE == 1
    [self setNeedsDisplay];
#else
    [self setNeedsDisplay:YES];
#endif
    
}

- (VCRect)hitTestRect
{
    return (CGRectInset(self.bounds, 16, 16));
}

- (VCRect)insetRect
{
    return CGRectInset(self.bounds, 4, 4);
}

- (id)clickDown:(VCEvent *)theEvent
{
    #if TARGET_OS_IPHONE
    VCPoint loc = [theEvent.allTouches.allObjects.lastObject locationInView:self];
    VCPoint thePoint = [self convertPoint:loc fromView:self.superview];
#else
    VCPoint thePoint = [self convertPoint:theEvent.locationInWindow fromView:self.superview];
#endif
    VCRect bangRect = [self hitTestRect];
    if (CGRectContainsPoint(bangRect, thePoint)) {
        [self sendBang];
        if (self.selected) {
            return self;
        }else{
            return nil;
        }
    }
#if TARGET_OS_IPHONE == 1
    if (theEvent)
        
#else
        if (theEvent.clickCount == 1)
            
#endif
        {
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


- (void)drawRect:(VCRect)dirtyRect {

    VCColor *backgroundColor = nil;
    
    if (self.selected) {
        backgroundColor = self.selectedColor;
    }else{
        backgroundColor = self.defaultColor;
    }
    
    [backgroundColor setFill];
    
    #if TARGET_OS_IPHONE == 1
    //TODO
#else
    NSRectFill(dirtyRect);
#endif
    // Drawing code here.
    
    VCRect insetRect = [self insetRect];
    VCBezierPath *bezierPath = [VCBezierPath bezierPathWithOvalInRect:insetRect];
    VCColor *fillColor = nil;
    
    if (self.sending) {
        fillColor = [self sendingColor];
    }else{
        fillColor = [self notSendingColor];
    }
    
    [fillColor setFill];
    [[VCColor blackColor]setStroke];
    [bezierPath setLineWidth:1];
    [bezierPath fill];
    [bezierPath stroke];
    
    VCBezierPath *outlinePath = [VCBezierPath bezierPathWithRect:self.bounds];
    [outlinePath stroke];
}

@end
