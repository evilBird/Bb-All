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

@implementation BbCocoaPatchView (Touches)

#pragma mark - mouse down

- (void)mouseDown:(NSEvent *)theEvent
{
    CGPoint loc = theEvent.locationInWindow;
    id theView = [self hitTest:loc];
    kClickCount = theEvent.clickCount;
    if (theEvent.clickCount == 1 && [theView respondsToSelector:@selector(viewType)]) {
        [self clickDown:theEvent inView:theView];
    }else if (theEvent.clickCount == 2){
        [self addPlaceholderAtPoint:theEvent.locationInWindow];
    }
    
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

#pragma mark - connections

- (void)connectSender:(NSUInteger)senderIndex
               outlet:(NSUInteger)outletIndex
             receiver:(NSUInteger)receiverIndex
                inlet:(NSUInteger)inletIndex
{
    BbPatch *patch = (BbPatch *)self.entity;
    id desc = [patch connectObject:senderIndex
                              port:outletIndex
                          toObject:receiverIndex
                              port:inletIndex];
    
    BbCocoaPatchGetConnectionArray block = [self pathArrayWithConnection:desc];
    if (block != NULL) {
        if (!self.connections) {
            self.connections = [[NSMutableSet alloc]init];
        }
        
        [self.connections addObject:block];
        
        //NSString *patchDescription = [patch textDescription];
        //NSLog(@"\n%@\n",patchDescription);
    }
}

- (void)connectPortView:(BbCocoaPortView *)sender toReceiver:(BbCocoaPortView *)receiver
{
    NSDictionary *senderInfo = [sender userInfo];
    NSDictionary *receiverInfo = [receiver userInfo];
    if (senderInfo && receiverInfo) {
        NSUInteger senderPortIndex = [senderInfo[@"port_index"]unsignedIntegerValue];
        NSUInteger senderParentIndex = [senderInfo[@"parent_index"]unsignedIntegerValue];
        NSUInteger receiverPortIndex = [receiverInfo[@"port_index"]unsignedIntegerValue];
        NSUInteger receiverParentIndex = [receiverInfo[@"parent_index"]unsignedIntegerValue];
        [self connectSender:senderParentIndex
                     outlet:senderPortIndex
                   receiver:receiverParentIndex
                      inlet:receiverPortIndex];
    }
}

#pragma mark - draw connections as paths

- (BbCocoaPatchGetConnectionArray)pathArrayWithConnection:(id)desc
{
    if (!desc) {
        return NULL;
    }
    
    BbConnectionDescription *c = desc;
    if (c.flag == BbConnectionDescriptionFlags_DELETE) {
        return NULL;
    }
    BbPatch *patch = (BbPatch *)self.entity;
    BbObject *sender = [patch childObjects][c.senderObjectIndex];
    BbOutlet *outlet = sender.outlets[c.senderPortIndex];
    BbObject *receiver = [patch childObjects][c.receiverObjectIndex];
    BbInlet *inlet = receiver.inlets[c.receiverPortIndex];
    BbCocoaPortView *outletView = (BbCocoaPortView *)outlet.view;
    BbCocoaPortView *inletView = (BbCocoaPortView *)inlet.view;
    
    if (!outletView || !inletView) {
        return NULL;
    }
    
    return [self connectionBlockSender:outletView receiver:inletView];
    
}
- (BbCocoaPatchGetConnectionArray)connectionBlockSender:(BbCocoaPortView *)sender receiver:(BbCocoaPortView *)receiver
{
    __weak BbCocoaPatchView *weakself = self;
    BbCocoaPatchGetConnectionArray connectionBlock = ^ NSArray *{
        
        CGRect senderRect = [weakself convertRect:sender.bounds fromView:sender];
        CGRect receiverRect = [weakself convertRect:receiver.bounds fromView:receiver];
        NSArray *senderPoint = @[@(CGRectGetMidX(senderRect)),@(CGRectGetMidY(senderRect))];
        NSArray *receiverPoint = @[@(CGRectGetMidX(receiverRect)),@(CGRectGetMidY(receiverRect))];
        NSArray *result = nil;
        if (senderPoint && receiverPoint) {
            NSMutableArray *temp = [NSMutableArray array];
            [temp addObjectsFromArray:senderPoint];
            [temp addObjectsFromArray:receiverPoint];
            result = [NSArray arrayWithArray:temp];
        }
        return result;
    };
    
    return connectionBlock;
}



@end
