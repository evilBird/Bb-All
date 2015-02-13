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
    }else if ([view isKindOfClass:[BbCocoaObjectView class]]||[view isKindOfClass:[BbCocoaPlaceholderObjectView class]]){
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
    BbEntity *entity = portView.entity;
    if ([entity isKindOfClass:[BbInlet class]]) {
        NSLog(@"click in inlet,returning");
        return;
    }
    kSelectedPortViewSender = portView;
    [kSelectedPortViewSender setSelected:YES];
    kPreviousLoc = theEvent.locationInWindow;
}

- (void)singleClickDown:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    kSelectedObjectView = objectView;
    NSPoint objectCenter = [self scaleNormalizedPoint:objectView.normalizedPosition];
    kInitOffset.width = (theEvent.locationInWindow.x - objectCenter.x);
    kInitOffset.height = (theEvent.locationInWindow.y - objectCenter.y);
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

- (NSPoint)normalizePoint:(NSPoint)point
{
    CGFloat x,y;
    x = (point.x * 100.0)/self.intrinsicContentSize.width;
    y = (point.y * 100.0)/self.intrinsicContentSize.height;
    CGPoint normPoint = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(normPoint);
}

- (NSPoint)scaleNormalizedPoint:(NSPoint)point
{
    CGFloat x,y;
    x = point.x * 0.01 * self.intrinsicContentSize.width;
    y = point.y * 0.01 * self.intrinsicContentSize.height;
    CGPoint scaledPoint = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(scaledPoint);
}

- (NSPoint)offsetScaledPoint:(NSPoint)point
{
    NSPoint p = point;
    p.x -= kInitOffset.width;
    p.y -= kInitOffset.height;
    return p;
}

- (NSPoint)myCenter
{
    CGFloat x,y;
    x = self.intrinsicContentSize.width/2.0;
    y = self.intrinsicContentSize.height/2.0;
    CGPoint myCenter = CGPointMake([NSView roundFloat:x], [NSView roundFloat:y]);
    return NSPointFromCGPoint(myCenter);
}

- (void)mouseDragged:(NSEvent *)theEvent fromObjectView:(BbCocoaObjectView *)objectView
{
    [self moveEntityView:objectView toPoint:[self offsetScaledPoint:theEvent.locationInWindow]];

    //[self moveEntityView:objectView toPoint:theEvent.locationInWindow];
}

- (void)moveEntityView:(BbCocoaEntityView *)entityView toPoint:(NSPoint)point
{
    CGFloat dx,dy;
    NSPoint myCenter = [self myCenter];
    dx = point.x - myCenter.x;
    dy = point.y - myCenter.y;
    [entityView.centerXConstraint autoRemove];
    [entityView.centerYConstraint autoRemove];
    entityView.centerXConstraint = [entityView autoAlignAxis:ALAxisVertical toSameAxisOfView:self withOffset:[NSView roundFloat:dx]];
    entityView.centerYConstraint = [entityView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-[NSView roundFloat:dy]];
    [entityView.centerXConstraint autoInstall];
    [entityView.centerYConstraint autoInstall];
    entityView.normalizedPosition = [self normalizePoint:point];
    [self setNeedsDisplay:YES];
    [self layoutSubtreeIfNeeded];
}

- (void)mouseDragged:(NSEvent *)theEvent fromPortView:(BbCocoaPortView *)portView
{
    BbViewType initViewType = [BbCocoaPatchView viewType:portView];
    BbEntity *entity = portView.entity;
    
    if (initViewType!=BbViewType_Port || [entity isKindOfClass:[BbInlet class]]) {
        return;
    }
    
    id newView = [self hitTest:theEvent.locationInWindow];
    if ([BbCocoaPatchView viewType:newView] == BbViewType_Port) {
        BbCocoaPortView *receiver = (BbCocoaPortView *)[self hitTest:theEvent.locationInWindow];
        if ([receiver.entity isKindOfClass:[BbInlet class]]) {
            [receiver setSelected:YES];
            kSelectedPortViewReceiver = receiver;
        }
    }
    
    CGRect bounds = portView.bounds;
    CGRect senderBounds = [self convertRect:bounds fromView:portView];
    CGPoint point = CGPointMake(CGRectGetMidX(senderBounds), CGRectGetMidY(senderBounds));//[portView convertPoint:oldCenter toView:self];
    
    CGFloat x1,y1,x2,y2;
    x1 = point.x;
    y1 = point.y;
    x2 = theEvent.locationInWindow.x;
    y2 = theEvent.locationInWindow.y;
    self.drawThisConnection = @[@(x1),@(y1),@(x2),@(y2)];
    [self setNeedsDisplay:YES];
}

#pragma mark - mouse moved

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSLog(@"mouse moved");
}


#pragma mark - mouse up

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
            [self singleClickUp:theEvent inView:theView];
            [self singleClickUp:theEvent inPortView:kSelectedPortViewSender];
            break;
    }
    
    [kSelectedObjectView setSelected:NO];
    kSelectedObjectView = nil;
    [kSelectedPortViewSender setSelected:NO];
    kSelectedPortViewSender = nil;
    [kSelectedPortViewReceiver setSelected:NO];
    kSelectedPortViewReceiver = nil;
    kInitView = nil;
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
    self.drawThisConnection = nil;
    [self setNeedsDisplay:YES];
}

- (void)singleClickUp:(NSEvent *)theEvent inObjectView:(BbCocoaObjectView *)objectView
{
    [kSelectedObjectView setSelected:NO];
    kSelectedObjectView = nil;
    kPreviousLoc = CGPointZero;
    kInitView = nil;
    kSelectedPortViewSender = nil;
    kSelectedPortViewReceiver = nil;
    self.drawThisConnection = nil;
    [self setNeedsDisplay:YES];
}

- (void)singleClickUp:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    if (kSelectedPortViewSender && kSelectedPortViewReceiver && kSelectedPortViewReceiver != kSelectedPortViewSender) {
        NSDictionary *senderInfo = [kSelectedPortViewSender userInfo];
        NSDictionary *receiverInfo = [kSelectedPortViewReceiver userInfo];
        if (senderInfo && receiverInfo) {
            NSUInteger senderPortIndex = [senderInfo[@"port_index"]unsignedIntegerValue];
            NSUInteger senderParentIndex = [senderInfo[@"parent_index"]unsignedIntegerValue];
            NSUInteger receiverPortIndex = [receiverInfo[@"port_index"]unsignedIntegerValue];
            NSUInteger receiverParentIndex = [receiverInfo[@"parent_index"]unsignedIntegerValue];
            BbPatch *patch = (BbPatch *)self.entity;
            [patch connectObject:senderParentIndex
                            port:senderPortIndex
                        toObject:receiverParentIndex
                            port:receiverPortIndex];
            
            NSLog(@"#X connect %@ %@ %@ %@;\n",senderInfo[@"parent_index"],senderInfo[@"port_index"],receiverInfo[@"parent_index"],receiverInfo[@"port_index"]);
            
            BbCocoaPatchGetConnectionArray block = [self connectionBlockSender:kSelectedPortViewSender receiver:kSelectedPortViewReceiver];
            if (!self.connections) {
                self.connections = [[NSMutableSet alloc]init];
            }
            
            [self.connections addObject:block];
        }
    }
    
    [kSelectedPortViewSender setSelected:NO];
    [kSelectedPortViewReceiver setSelected:NO];
    kSelectedPortViewSender = nil;
    kSelectedPortViewReceiver = nil;
    kPreviousLoc = CGPointZero;
    kInitView = nil;
    self.drawThisConnection = nil;
    [self setNeedsDisplay:YES];
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

- (void)doubleClickUp:(NSEvent *)theEvent inView:(id)theView
{
    BbViewType viewType = [BbCocoaPatchView viewType:theView];
    if (viewType == BbViewType_Patch) {
        kInitView = nil;
        kSelectedObjectView = nil;
        kSelectedPortViewSender = nil;
        kSelectedPortViewReceiver = nil;
        [self setNeedsDisplay:YES];
        
        [self addPlaceholderAtPoint:theEvent.locationInWindow];

    }
}

- (void)rightClickUp:(NSEvent *)theEvent inView:(id)theView
{
    
}

@end
