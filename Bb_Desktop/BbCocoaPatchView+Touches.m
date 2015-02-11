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
#import "BbObject.h"

typedef NS_ENUM(NSUInteger, BbViewType){
    BbViewType_Port,
    BbViewType_Object,
    BbViewType_Patch,
    BbViewType_None
};

@implementation BbCocoaPatchView (Touches)


+ (BbViewType)viewType:(id)view
{
    BbViewType viewType;
    if ([view isKindOfClass:[BbCocoaPortView class]]) {
        viewType = BbViewType_Port;
    }else if ([view isMemberOfClass:[BbCocoaObjectView class]]){
        viewType = BbViewType_Object;
    }else if ([view isKindOfClass:[BbCocoaPatchView class]]){
        viewType = BbViewType_Patch;
    }else{
        viewType = BbViewType_None;
    }
    
    return viewType;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    
    switch (theEvent.clickCount) {
        case 1:
            kInitView = theView;
            [self singleClickDown:theEvent inView:theView];
            break;
        case 2:
            [self doubleClickDown:theEvent inView:theView];
            break;
        default:
            break;
    }
}

#pragma mark - single click down

- (void)singleClickDown:(NSEvent *)theEvent inView:(id)theView
{
    BbViewType viewType = [BbCocoaPatchView viewType:theView];
    switch (viewType) {
        case BbViewType_Port:
            [self singleClickDown:theEvent inPortView:theView];
            break;
        case BbViewType_Object:
            [self singleClickDown:theEvent inObjectView:theView];
            break;
        case BbViewType_Patch:
            [self singleClickDown:theEvent inPatchView:theView];
            break;
        case BbViewType_None:
            NSLog(@"single click down in unknown view type: %@",theView);
            break;
        default:
            NSLog(@"single click down in unknown view type: %@",theView);
            break;
    }
}

- (void)singleClickDown:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    if (!self.selectedPortViews) {
        self.selectedPortViews = [[NSMutableSet alloc]init];
    }
    
    kSelectedPortView = portView;
    [kSelectedPortView setSelected:YES];
    [self.selectedPortViews addObject:kSelectedPortView];
    kPreviousLoc = theEvent.locationInWindow;
    
    BbPort *port = (BbPort *)portView.entity;
    NSUInteger index = [port.parent indexForPort:port];
    NSLog(@"port index: %@",@(index));
}

- (void)singleClickDown:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    kSelectedObjectView = objectView;
    [kSelectedObjectView setSelected:YES];
    kPreviousLoc = theEvent.locationInWindow;
}

- (void)singleClickDown:(NSEvent *)theEvent inPatchView:(BbCocoaPatchView *)patchView
{
    NSLog(@"single click down in patchview");
}

#pragma mark - double click down

- (void)doubleClickDown:(NSEvent *)theEvent inView:(id)theView
{
    BbViewType viewType = [BbCocoaPatchView viewType:theView];
    switch (viewType) {
        case BbViewType_Port:
            [self doubleClickDown:theEvent inPortView:theView];
            break;
        case BbViewType_Object:
            [self doubleClickDown:theEvent inObjectView:theView];
            break;
        case BbViewType_Patch:
            [self doubleClickDown:theEvent inPatchView:theView];
            break;
        case BbViewType_None:
            NSLog(@"double click down in unknown view type: %@",theView);
            break;
        default:
            NSLog(@"double click down in unknown view type: %@",theView);
            break;
    }
}

- (void)doubleClickDown:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    
}

- (void)doubleClickDown:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    
}

- (void)doubleClickDown:(NSEvent *)theEvent inPatchView:(BbCocoaPatchView *)patchView
{
    
}

#pragma mark - Right click down

- (void)rightMouseDown:(NSEvent *)theEvent
{
    id theView = [self hitTest:theEvent.locationInWindow];
    [self rightClickDown:theEvent inView:theView];
}

- (void)rightClickDown:(NSEvent *)theEvent inView:(id)theView
{
    BbViewType viewType = [BbCocoaPatchView viewType:theView];
    switch (viewType) {
        case BbViewType_Port:
            [self rightClickDown:theEvent inPortView:theView];
            break;
        case BbViewType_Object:
            [self rightClickDown:theEvent inObjectView:theView];
            break;
        case BbViewType_Patch:
            [self rightClickDown:theEvent inPatchView:theView];
            break;
        case BbViewType_None:
            NSLog(@"right click down in unknown view type: %@",theView);
            break;
        default:
            NSLog(@"right click down in unknown view type: %@",theView);
            break;
    }
}

- (void)rightClickDown:(NSEvent *)theEvent inPatchView:(BbCocoaPatchView *)patchView
{
    
}

- (void)rightClickDown:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    
}

- (void)rightClickDown:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    
}

#pragma mark - Mouse dragged

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (kInitView == nil) {
        return;
    }
    
    BbViewType viewType = [BbCocoaPatchView viewType:kInitView];
    switch (viewType) {
        case BbViewType_Port:
            [self mouseDragged:theEvent fromPortView:kInitView];
            break;
        case BbViewType_Object:
            [self mouseDragged:theEvent fromObjectView:kInitView];
            break;
        case BbViewType_Patch:
            [self mouseDragged:theEvent fromPatchView:kInitView];
            break;
        case BbViewType_None:
            NSLog(@"mouse dragged from unknown view type: %@",kInitView);
            break;
            
        default:
            NSLog(@"mouse dragged from unknown view type: %@",kInitView);
            break;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent fromPatchView:(BbCocoaPatchView *)patchView
{
    NSLog(@"mouse dragged from patch view");
}

- (void)mouseDragged:(NSEvent *)theEvent fromObjectView:(BbCocoaObjectView *)objectView
{
    NSPoint loc = theEvent.locationInWindow;
    CGFloat dx = loc.x - kPreviousLoc.x;
    CGFloat dy = loc.y - kPreviousLoc.y;
    CGPoint oldCenter = [objectView center];
    CGPoint newCenter = oldCenter;
    newCenter.x += dx;
    newCenter.y += dy;
    CGRect oldFrame = objectView.frame;
    CGRect newFrame = CGRectOffset(oldFrame, dx, dy);
    objectView.frame = newFrame;
    [objectView setCenter:newCenter];
    kPreviousLoc = loc;
}

- (void)mouseDragged:(NSEvent *)theEvent fromPortView:(BbCocoaPortView *)portView
{
    //NSLog(@"mouse dragged from port view");
}

#pragma mark - mouse moved

- (void)mouseMoved:(NSEvent *)theEvent
{
    /*
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
     */
    NSLog(@"mouse moved");
}

- (void)mouseUp:(NSEvent *)theEvent
{
    id theView = [self hitTest:theEvent.locationInWindow];
    
    switch (theEvent.clickCount) {
        case 1:
            [self singleClickUp:theEvent inView:theView];
            break;
        case 2:
            [self doubleClickUp:theEvent inView:theView];
            break;
        default:
            break;
    }
}

- (void)singleClickUp:(NSEvent *)theEvent inView:(id)theView
{
    BbViewType viewType = [BbCocoaPatchView viewType:theView];
    switch (viewType) {
        case BbViewType_Port:
            [self singleClickUp:theEvent inPortView:theView];
            break;
        case BbViewType_Object:
            [self singleClickUp:theEvent inObjectView:theView];
            break;
        case BbViewType_Patch:
            [self singleClickUp:theEvent inPatchView:theView];
            break;
        case BbViewType_None:
            kInitView = nil;
            NSLog(@"single click down in unknown view type: %@",theView);
            break;
        default:
            kInitView = nil;
            NSLog(@"single click down in unknown view type: %@",theView);
            break;
    }
}

- (void)singleClickUp:(NSEvent *)theEvent inPatchView:(BbCocoaPatchView *)patchView
{
    kInitView = nil;
}

- (void)singleClickUp:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    [kSelectedObjectView setSelected:NO];
    kSelectedObjectView = nil;
    kPreviousLoc = CGPointZero;
    kInitView = nil;
}

- (void)singleClickUp:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    [kSelectedPortView setSelected:NO];
    if (self.selectedPortViews) {
        for (BbCocoaPortView *aPortView in self.selectedPortViews) {
            [aPortView setSelected:NO];
        }
        
        [self.selectedPortViews removeAllObjects];
        self.selectedPortViews = nil;
    }
    
    kSelectedPortView = nil;
    kPreviousLoc = CGPointZero;
    kInitView = nil;
}

- (void)doubleClickUp:(NSEvent *)theEvent inView:(id)theView
{
    
}

- (void)rightClickUp:(NSEvent *)theEvent inView:(id)theView
{
    
}

@end
