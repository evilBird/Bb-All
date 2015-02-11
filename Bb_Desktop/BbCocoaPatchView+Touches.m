//
//  BbCocoaPatchView+Touches.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPatchView+Touches.h"
#import "BbCocoaObjectView.h"
#import "BbCocoaPortView.h"
#import "BbCocoaEntityView.h"

@implementation BbCocoaPatchView (Touches)

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    
    if (![theView conformsToProtocol:@protocol(BbEntityView)]) {
        return;
    }
    
    if ([theView isKindOfClass:[BbCocoaPortView class]]) {
        
        if (!self.selectedPortViews) {
            self.selectedPortViews = [[NSMutableSet alloc]init];
        }
        
        kSelectedPortView = theView;
        [kSelectedPortView setSelected:YES];
        [self.selectedPortViews addObject:kSelectedPortView];
        kPreviousLoc = loc;
    }
    
    if ([theView isKindOfClass:[BbCocoaObjectView class]]){
        kSelectedObjectView = (id<BbEntityView>)theView;
        [kSelectedObjectView setSelected:YES];
        kPreviousLoc = loc;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    
    if (kSelectedObjectView) {
        NSPoint loc = theEvent.locationInWindow;
        CGFloat dx = loc.x - kPreviousLoc.x;
        CGFloat dy = loc.y - kPreviousLoc.y;
        CGPoint oldCenter = [kSelectedObjectView center];
        CGPoint newCenter = oldCenter;
        newCenter.x += dx;
        newCenter.y += dy;
        CGRect oldFrame = kSelectedObjectView.frame;
        CGRect newFrame = CGRectOffset(oldFrame, dx, dy);
        kSelectedObjectView.frame = newFrame;
        [kSelectedObjectView setCenter:newCenter];
        kPreviousLoc = loc;
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    if (kSelectedObjectView) {
        NSPoint loc = theEvent.locationInWindow;
        CGFloat dx = loc.x - kPreviousLoc.x;
        CGFloat dy = loc.y - kPreviousLoc.y;
        CGRect oldFrame = kSelectedObjectView.frame;
        CGRect newFrame = CGRectOffset(oldFrame, dx, dy);
        kSelectedObjectView.frame = newFrame;
        kPreviousLoc = loc;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    if (kSelectedObjectView) {
        [kSelectedObjectView setSelected:NO];
        kSelectedObjectView = nil;
        kPreviousLoc = CGPointZero;
    }
    
    if (self.selectedPortViews) {
        [kSelectedPortView setSelected:NO];
        kSelectedPortView = nil;
        NSMutableArray *selectedPortViews = self.selectedPortViews.allObjects.mutableCopy;
        for (BbCocoaPortView *portView in selectedPortViews) {
            [portView setSelected:NO];
        }
        [self.selectedPortViews removeAllObjects];
        self.selectedPortViews = nil;
    }
}

@end
