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
    BbEntity *entity = portView.entity;
    if ([entity isKindOfClass:[BbInlet class]]) {
        NSLog(@"click in inlet,returning");
        return;
    }
    
   // if (!self.selectedPortViews) {
     //   self.selectedPortViews = [[NSMutableSet alloc]init];
   // }
    
    kSelectedPortViewSender = portView;
    [kSelectedPortViewSender setSelected:YES];
    //[self.selectedPortViews addObject:kSelectedPortViewSender];
    kPreviousLoc = theEvent.locationInWindow;
    
    NSLog(@"port info: %@",[portView userInfo]);
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
    [self setNeedsDisplay:YES];
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
        [receiver setSelected:YES];
        kSelectedPortViewReceiver = receiver;
    }
    
    CGPoint oldCenter = portView.center;
    CGPoint point = [portView convertPoint:oldCenter toView:self];
    
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

#pragma mark - mouse entered

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSLog(@"mouse entered");
    id theView = [self hitTest:theEvent.locationInWindow];
    BbViewType newViewType = [BbCocoaPatchView viewType:theView];
    BbViewType initViewType = [BbCocoaPatchView viewType:kInitView];
    if (newViewType == initViewType == BbViewType_Port) {
        BbEntity *newEntity = [(BbCocoaPortView *)theView entity];
        BbEntity *initEntity = [(BbCocoaPortView *)kInitView entity];
        if ([newEntity isKindOfClass:[BbInlet class]]&&[initEntity isKindOfClass:[BbOutlet class]]) {
            [self mouseEntered:theEvent portView:theView];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent portView:(BbCocoaPortView *)portView
{
    portView.selected = YES;
    NSLog(@"mouse entered portview");
    kPreviousLoc = theEvent.locationInWindow;
}

#pragma mark - mouse exited

- (void)mouseExited:(NSEvent *)theEvent
{
    NSLog(@"mouse exited");
}

- (void)mouseExited:(NSEvent *)theEvent portView:(BbCocoaPortView *)portView
{
    
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
    self.drawThisConnection = nil;
    [self setNeedsDisplay:YES];
}

- (void)singleClickUp:(NSEvent *)theEvent inPortView:(BbCocoaPortView *)portView
{
    if (kSelectedPortViewSender && kSelectedPortViewReceiver && kSelectedPortViewReceiver != kSelectedPortViewSender) {
        NSDictionary *senderInfo = [kSelectedPortViewSender userInfo];
        NSDictionary *receiverInfo = [kSelectedPortViewReceiver userInfo];
        if (senderInfo && receiverInfo) {
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
}

- (BbCocoaPatchGetConnectionArray)connectionBlockSender:(BbCocoaPortView *)sender receiver:(BbCocoaPortView *)receiver
{
    BbCocoaPatchGetConnectionArray connectionBlock = ^ NSArray *{
        NSDictionary *senderInfo = [sender userInfo];
        NSDictionary *receiverInfo = [receiver userInfo];
        NSArray *senderPoint = senderInfo[@"center"];
        NSArray *receiverPoint = receiverInfo[@"center"];
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
        CGPoint point = theEvent.locationInWindow;
        NSString *textDescription = [NSString stringWithFormat:@"#X BbObject %.f %.f BbObject;\n",point.x,point.y];
        [self addObjectAndViewWithText:textDescription];
    }
}

- (void)rightClickUp:(NSEvent *)theEvent inView:(id)theView
{
    
}

@end
