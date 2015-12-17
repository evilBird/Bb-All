//
//  ViewController+Touches.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "ViewController+Touches.h"
#import "ObjectView.h"

@implementation ViewController (Touches)

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self.view hitTest:loc];
    
    if (![theView conformsToProtocol:@protocol(BbEntityView)]) {
        return;
    }
    
    if ([theView isKindOfClass:[BbPortView class]]) {
        
        if (!self.selectedPortViews) {
            self.selectedPortViews = [[NSMutableSet alloc]init];
        }
        
        self.selectedPortView = theView;
        [self.selectedPortView setSelected:YES];
        [self.selectedPortViews addObject:theView];
        self.prevMouseLoc = loc;
    }
    
    if ([theView isKindOfClass:[BbBoxView class]]){
        self.selectedObject = (id<BbEntityView>)theView;
        [self.selectedObject setSelected:YES];
        self.prevMouseLoc = loc;
    }
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self.view hitTest:loc];
    
    if (self.selectedObject) {
        NSPoint loc = theEvent.locationInWindow;
        CGFloat dx = loc.x - self.prevMouseLoc.x;
        CGFloat dy = loc.y - self.prevMouseLoc.y;
        CGRect oldFrame = self.selectedObject.frame;
        CGRect newFrame = CGRectOffset(oldFrame, dx, dy);
        self.selectedObject.frame = newFrame;
        self.prevMouseLoc = loc;
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self.view hitTest:loc];
    if (self.selectedObject) {
        NSPoint loc = theEvent.locationInWindow;
        CGFloat dx = loc.x - self.prevMouseLoc.x;
        CGFloat dy = loc.y - self.prevMouseLoc.y;
        CGRect oldFrame = self.selectedObject.frame;
        CGRect newFrame = CGRectOffset(oldFrame, dx, dy);
        self.selectedObject.frame = newFrame;
        self.prevMouseLoc = loc;
    }
    
}

- (void)mouseUp:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self.view hitTest:loc];
    if (self.selectedObject) {
        self.selectedObject = nil;
        self.prevMouseLoc = CGPointZero;
        [(id<BbEntityView>)theView setSelected:NO];
    }
    
    if (self.selectedPortViews) {
        NSMutableArray *selectedPortViews = self.selectedPortViews.allObjects.mutableCopy;
        for (id<BbEntityView>portView in selectedPortViews) {
            [portView setSelected:NO];
        }
        [self.selectedPortViews removeAllObjects];
        self.selectedPortViews = nil;
    }
}

- (CGPoint)centerForFrame:(CGRect)frame
{
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

@end
