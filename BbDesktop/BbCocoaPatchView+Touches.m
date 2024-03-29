
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
#import "BbPatch.h"
#import "BbCocoaPlaceholderObjectView.h"
#import "BbCocoaEntityView+Touches.h"
#import "BbCocoaPatchView+Helpers.h"
#import "BbCocoaPatchView+Connections.h"

@implementation BbCocoaPatchView (Touches)

#pragma mark - mouse down

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    id superView = [theView superview];
    id myView = nil;
    
    if (![theView respondsToSelector:@selector(viewType)] && [superView respondsToSelector:@selector(editing)]) {
        BOOL editing = [superView editing];
        if (editing) {
            return;
        }
        
        myView = superView;
    }else{
        myView = theView;
    }
    
    kClickCount = theEvent.clickCount;
    
    if ([myView viewType] == BbViewType_Patch) {
        if (theEvent.clickCount == 1) {
            [self hitTestConnections:self.connections.mutableCopy withPoint:loc];
            return;
        }else if (theEvent.clickCount == 2){
            [self addPlaceholderAtPoint:theEvent.locationInWindow];
            return;
        }
    }
    
    [self clickDown:theEvent inView:myView];
    kPreviousLoc = theEvent.locationInWindow;
}

- (void)clickDown:(NSEvent *)theEvent inView:(id)theView
{
    self.initialTouchView = theView;
    BbViewType viewType = [theView viewType];
    
    switch (viewType) {
        case BbViewType_Port:
            self.selectedPortViewSender = [theView clickDown:theEvent];
            break;
        case BbViewType_Object:
            self.selectedObjectView = [theView clickDown:theEvent];
            kInitOffset = [self initOffsetObjectView:self.selectedObjectView
                                               event:theEvent];
            break;
        default:
            break;
    }
}

#pragma mark - Right click down

- (void)rightMouseDown:(NSEvent *)theEvent {}

- (void)rightClickDown:(NSEvent *)theEvent inView:(id)theView {}


#pragma mark - Mouse dragged

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (self.initialTouchView == nil) {
        return;
    }
    
    if (self.initialTouchView == self.selectedPortViewSender) {
        
        [self drawPathFromPortView:self.selectedPortViewSender
                           toPoint:theEvent.locationInWindow];
        
        id newView = [self hitTest:theEvent.locationInWindow];
        if ([newView isKindOfClass:[BbCocoaPortView class]] && newView != self.selectedPortViewSender) {
            self.selectedPortViewReceiver = [newView boundsWereEntered:theEvent];
        }else{
            self.selectedPortViewReceiver = [self.selectedPortViewReceiver boundsWereExited:theEvent];
        }
        
    }else if (self.initialTouchView == self.selectedObjectView){
        
        [self moveEntityView:self.selectedObjectView
                     toPoint:[self offsetScaledPoint:theEvent.locationInWindow]];
        
    }
    
    kPreviousLoc = theEvent.locationInWindow;
}

#pragma mark - mouse up

- (void)mouseUp:(NSEvent *)theEvent
{
    if (!self.initialTouchView) {
        return;
    }
    id endView = [self hitTest:theEvent.locationInWindow];
    if ([endView isKindOfClass:[BbCocoaPortView class]] && endView != self.selectedPortViewSender) {
        self.selectedPortViewReceiver = [endView boundsWereEntered:theEvent];
    }else{
        self.selectedPortViewReceiver = [self.selectedPortViewReceiver boundsWereExited:theEvent];
    }
    
    [self touchesEnded:theEvent];
    kPreviousLoc = theEvent.locationInWindow;
}

- (void)touchesEnded:(NSEvent *)theEvent
{
    
    if (self.initialTouchView == self && theEvent.clickCount == 2) {
        [self addPlaceholderAtPoint:theEvent.locationInWindow];
    }
    self.initialTouchView = nil;
    self.drawThisConnection = nil;

    self.selectedObjectView = [self.selectedObjectView clickUp:theEvent];
    
    if (self.selectedPortViewSender && self.selectedPortViewReceiver) {
        [self connectPortView:self.selectedPortViewSender
                   toReceiver:self.selectedPortViewReceiver];
    }
    
    self.selectedPortViewSender = [self.selectedPortViewSender clickUp:theEvent];
    self.selectedPortViewReceiver = [self.selectedPortViewReceiver clickUp:theEvent];
    
    [self setNeedsDisplay:YES];
}

#pragma mark - Key down

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *theKey = theEvent.characters;
    if ([theKey isEqualToString:@"\x7f"] && self.selectedConnections) {
        for (NSString *connectionId in self.selectedConnections.allObjects) {
            if ([self.patch hasConnectionWithId:connectionId]) {
                [self.patch deleteConnectionWithId:connectionId];
            }else{
                NSLog(@"patch doesn't have a connection with id %@",connectionId);
            }
        }
    }

}

@end
