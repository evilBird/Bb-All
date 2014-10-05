//
//  BSDCanvas.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/4/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDCanvas.h"
#import "BSDCompiledPatch.h"
#import "BSDNumberBox.h"
#import "BSDBangControlBox.h"
#import "BSDObjects.h"
#import "BSDObject.h"
#import "BSDMessageBox.h"
#import "BSDInletBox.h"
#import "BSDOutletBox.h"
#import <ObjC/runtime.h>
#import "NSUserDefaults+HBVUtils.h"
#import "BSDCommentBox.h"
#import "BSDPatchDescription.h"

@interface BSDCanvas ()<UIGestureRecognizerDelegate,BSDScreenDelegate>
{
    CGPoint kFocusPoint;
}


@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;
@property (nonatomic,strong)NSMutableDictionary *bezierPaths;
@property (nonatomic,strong)NSArray *allowedObjects;
@property (nonatomic,strong)BSDGraphBox *screenBox;
@property (nonatomic,strong)BSDPatchDescription *patchDescription;

@end

@implementation BSDCanvas

#pragma mark - edit state management

- (void)setEditState:(BSDCanvasEditState)editState
{
    if (editState != _editState) {
        _editState = editState;
        [self editStateChanged:editState];
    }
}

- (void)editStateChanged:(BSDCanvasEditState)editState
{
    switch (editState) {
        case BSDCanvasEditStateDefault:[self endEditing];
            break;
        case BSDCanvasEditStateEditing:[self beginEditing];
            break;
        case BSDCanvasEditStateContentSelected:
            [self.delegate canvas:self editingStateChanged:editState];
            break;
        case BSDCanvasEditStateContentCopied:
            [self.delegate canvas:self editingStateChanged:editState];
            break;
            
        default:
            break;
    }
}

- (void)beginEditing
{
    self.singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.delegate = self;
    [self addGestureRecognizer:self.singleTap];
    self.doubleTap.enabled = NO;
    for (NSString *boxId in self.boxes.allKeys) {
        id box = self.boxes[boxId];
        if ([box isKindOfClass:[BSDGraphBox class]] || [box isKindOfClass:[BSDMessageBox class]] || [box isKindOfClass:[BSDNumberBox class]]) {
            UITextField *textField = [box valueForKey:@"textField"];
            [textField setEnabled:NO];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)endEditing
{
    [self removeGestureRecognizer:self.singleTap];
    self.singleTap.delegate = nil;
    self.singleTap = nil;
    for (NSString *boxId in self.boxes.allKeys) {
        id box = self.boxes[boxId];
        if ([box isKindOfClass:[BSDGraphBox class]] || [box isKindOfClass:[BSDMessageBox class]] || [box isKindOfClass:[BSDNumberBox class]]) {
            UITextField *textField = [box valueForKey:@"textField"];
            [textField setEnabled:YES];
        }
    }
    self.doubleTap.enabled = YES;
    [self.selectedBoxes removeAllObjects];
    self.selectedBoxes = nil;
    [self.copiedBoxes removeAllObjects];
    self.copiedBoxes = nil;
    for (NSString *uniqueId in self.boxes.allKeys) {
        BSDBox *box = self.boxes[uniqueId];
        [box setSelected:NO];
    }
}

- (void)copySelectedContent
{
    if (!self.selectedBoxes) {
        return;
    }
    
    if (self.copiedBoxes) {
        [self.copiedBoxes removeAllObjects];
        self.copiedBoxes = nil;
    }
    
    NSDictionary *descriptions = [self descriptionsForBoxesInDictionary:self.selectedBoxes];
    self.copiedBoxes = [NSMutableDictionary dictionaryWithDictionary:descriptions];
    if (self.copiedBoxes) {
        self.editState = BSDCanvasEditStateContentCopied;
    }
}

- (void)deleteSelectedContent
{
    if (!self.selectedBoxes) {
        return;
    }
    
    for (NSString *uniqueId in self.selectedBoxes.allKeys) {
        if ([self.boxes.allKeys containsObject:uniqueId]) {
            BSDBox *box = self.boxes[uniqueId];
            [self.boxes removeObjectForKey:uniqueId];
            [self.graphBoxes removeObject:box];
            [box removeFromSuperview];
            [box tearDown];
        }
    }
    
    [self boxDidMove:nil];
    [self.selectedBoxes removeAllObjects];
    self.selectedBoxes = nil;
    self.editState = BSDCanvasEditStateEditing;
}

- (void)pasteSelectedContent
{
    if (!self.copiedBoxes){
        return;
    }
    
    NSString *appendId = [NSString stringWithFormat:@"-%@",@(arc4random_uniform(1000))];
    [self loadPatchWithDictionary:self.copiedBoxes appendId:appendId];
}

- (void)encapsulatedCopiedContentWithName:(NSString *)name
{
    NSMutableDictionary *toEncapsulate = [self.copiedBoxes mutableCopy];
    [self.delegate saveAbstraction:toEncapsulate withName:name];
    [self addGraphBoxAtPoint:kFocusPoint];
    BSDGraphBox *box = self.graphBoxes.lastObject;
    [box createObjectWithName:@"BSDCompiledPatch" arguments:@[name]];
    [self deleteSelectedContent];
    
}

- (NSString *)canvasId
{
    return [NSString stringWithFormat:@"%@",self];
}

#pragma mark - touch handling methods

- (void)checkForAbstractionInView:(UIView *)view
{
    BSDGraphBox *box = nil;
    if ([view isKindOfClass:[BSDGraphBox class]]) {
        box = (BSDGraphBox *)view;
    }else if ([view.superview isKindOfClass:[BSDGraphBox class]]){
        box = (BSDGraphBox *)view.superview;
    }
    
    if (box) {
        NSString *className = box.className;
        if ([className isEqualToString:@"BSDCompiledPatch"]) {
            NSArray *components = [box.textField.text componentsSeparatedByString:@" "];
            if (components.count > 1) {
                NSString *patchName = components[1];
                BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
                NSArray *patches = [lookup patchList];
                if ([patches containsObject:patchName]) {
                    [self openAbstraction:patchName];
                }
            }
        }
    }
}

- (void)openAbstraction:(id)abs
{
    [self.delegate saveCurrentPatch];
    [self.delegate loadAbstraction:abs];
}

- (void)handleLongPress:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    UIView *theView = [self hitTest:loc withEvent:UIEventTypeTouches];
    [self checkForAbstractionInView:theView];
}

- (void)handleSingleTap:(id)sender
{
    if (self.editState == 0 || (sender != self.singleTap)) {
        return;
    }
    
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    kFocusPoint = loc;
    UIView *theView = [self hitTest:loc withEvent:UIEventTypeTouches];
    BSDBox *toSelect = nil;
    id superview= theView.superview;
    NSInteger isBox = [theView isKindOfClass:[BSDBox class]];
    isBox += [superview isKindOfClass:[BSDBox class]];
    isBox += [theView isKindOfClass:[BSDGraphBox class]];
    isBox += [superview isKindOfClass:[BSDGraphBox class]];
    
    if (isBox == 0) {
        return;
    }
    
    if (![theView isKindOfClass:[BSDBox class]]) {
        toSelect = (BSDBox *)theView.superview;
    }else{
        toSelect= (BSDBox *)theView;
    }
    BOOL selected = toSelect.selected;
    if (selected) {
        toSelect.selected = NO;
    }else{
        toSelect.selected = YES;
    }
    
    if (!self.selectedBoxes) {
        self.selectedBoxes = [NSMutableDictionary dictionary];
    }
    if (toSelect.selected) {
        self.selectedBoxes[[toSelect uniqueId]] = toSelect;
    }else{
        if ([self.selectedBoxes.allKeys containsObject:[toSelect uniqueId]]) {
            
            [self.selectedBoxes removeObjectForKey:[toSelect uniqueId]];
        }
    }
    if (self.selectedBoxes.allKeys.count) {
        self.editState = BSDCanvasEditStateContentSelected;
    }
}

- (void)handleDoubleTap:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    kFocusPoint = loc;
    UIView *theView = [self hitTest:loc withEvent:UIEventTypeTouches];
    if ([theView isKindOfClass:[BSDBox class]] || [theView.superview isKindOfClass:[BSDBox class]] || [theView isKindOfClass:[UITextField class]] || [theView isKindOfClass:[BSDTextField class]]) {
        [self checkForAbstractionInView:theView];
        return;
    }
    
    [self addGraphBoxAtPoint:loc];
    
}

#pragma mark - BSDBoxDelegate

- (void)box:(id)sender portView:(id)portView drawLineToPoint:(CGPoint)point
{
    BSDPortView *pv = portView;
    BSDBox *gb = sender;
    CGPoint center = CGPointMake(CGRectGetMidX(pv.frame), CGRectGetMidY(pv.frame));
    CGPoint portViewCenter = [gb convertPoint:center toView:self];
    self.connectionOriginPoint = [NSValue valueWithCGPoint:portViewCenter];
    self.connectionDestinationPoint = [NSValue valueWithCGPoint:point];
    [self setNeedsDisplay];
    
    UIView *view = [self hitTest:point withEvent:UIEventTypeTouches];
    if ([view isKindOfClass:[BSDPortView class]]) {
        BSDPortView *targetPort = (BSDPortView *)view;
        BSDBox *targetBox = (BSDBox *)targetPort.delegate;
        [targetBox setSelectedPortView:targetPort];
    }
}

- (void)box:(id)sender portView:(id)portView endedAtPoint:(CGPoint)point
{
    BSDPortView *pv = portView;
    UIView *theView = [self hitTest:point withEvent:nil];
    
    if ([theView isKindOfClass:[BSDPortView class]]) {
        BSDPortView *newConnection = (BSDPortView *)theView;
        BSDBox *newBox = (BSDBox *)newConnection.delegate;
        [pv addConnectionToPortView:newConnection];
        [self connectPortView:pv toPortView:newConnection];
        [newBox setSelectedPortView:nil];
    }
    
    [sender setSelectedPortView:nil];
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.connectionPaths = nil;
    self.bezierPaths = nil;
    self.connectionPaths = [NSMutableArray arrayWithArray:[self allConnections]];
    kFocusPoint = point;
    [self setNeedsDisplay];
    
    for (BSDBox *box in self.boxes.allValues) {
        [box setSelectedPortView:nil];
    }
}

- (void)boxDidMove:(id)sender
{
    self.connectionPaths = nil;
    self.connectionPaths = [NSMutableArray arrayWithArray:[self allConnections]];
    [self setNeedsDisplay];
}

- (id)boxWithUniqueId:(NSString *)uniqueId
{
    if ([self.boxes.allKeys containsObject:uniqueId]) {
        return self.boxes[uniqueId];
    }
    
    return nil;
}

- (NSString *)getClassNameForText:(NSString *)text
{
    BSDObjectLookup *lookup = [[BSDObjectLookup alloc]init];
    return [lookup classNameForString:text];
}

- (UIView *)displayViewForBox:(id)sender
{
    return [self.delegate viewForCanvas:self];
}

#pragma mark - manage connections

- (void)connectPortView:(BSDPortView *)sender toPortView:(BSDPortView *)receiver
{
    BSDPortConnectionDescription *cd = [[BSDPortConnectionDescription alloc]init];
    cd.senderParentId = [sender.delegate parentId];
    cd.senderPortName = [sender portName];
    cd.receiverParentId = [receiver.delegate parentId];
    cd.receiverPortName = [receiver portName];
    cd.receiverPortView = receiver;
    BSDBox *sb = (BSDBox *)sender.delegate;
    [sb makeConnectionWithDescription:cd];
    
}

- (NSArray *)allConnections
{
    NSMutableArray *temp = [NSMutableArray array];
    for (BSDBox *gb in self.boxes.allValues) {
        NSArray *connections = [gb connectionVectors];
        if (connections) {
            [temp addObjectsFromArray:connections];
        }
    }
    return temp;
}

#pragma mark - Patch management

- (NSDictionary *)currentPatch
{
    [self describeYourself];
    return [self descriptionsForBoxesInDictionary:self.boxes];
}

- (NSDictionary *)descriptionsForBoxesInDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *objectDescriptions = [NSMutableArray array];
    NSMutableArray *connectionDescriptions = [NSMutableArray array];
    //enumerate all boxes, get object descriptions for each
    for (BSDBox *box in dictionary.allValues) {
        BSDObjectDescription *desc = [box objectDescription];
        NSDictionary *d = [desc dictionaryRespresentation];
        if (d) {
            [objectDescriptions addObject:d];
        }
        
        NSArray *cd = [box connectionDescriptions];
        if (cd) {
            [connectionDescriptions addObjectsFromArray:cd];
        }
    }
    
    NSDictionary *result = @{@"objectDescriptions":[NSArray arrayWithArray:objectDescriptions],
                             @"connectionDescriptions":[NSArray arrayWithArray:connectionDescriptions]
                             };
    return result;

}

- (void)loadPatchWithDictionary:(NSDictionary *)dictionary
{
    [self loadPatchWithDictionary:dictionary appendId:nil];
}

- (void)loadPatchWithDictionary:(NSDictionary *)dictionary appendId:(NSString *)appendId
{
    if (!dictionary) {
        return;
    }
    
    NSArray *objs = dictionary[@"objectDescriptions"];
    NSArray *connects = dictionary[@"connectionDescriptions"];
    NSMutableArray *loadBangs = nil;
    for (NSDictionary *dict in objs) {
        BSDObjectDescription *desc = [BSDObjectDescription objectDescriptionWithDictionary:dict appendId:appendId];
        [self makeBoxWithDescription:desc];
        if ([desc.className isEqualToString:@"BSDLoadBang"]) {
            
            BSDBox *box = self.boxes[desc.uniqueId];
            BSDLoadBang *lb = box.object;
            if (lb && [lb isKindOfClass:[BSDLoadBang class]]) {
                if (!loadBangs) {
                    loadBangs = [NSMutableArray array];
                }
                
                [loadBangs addObject:lb];
            }
        }
    }
    
    for (NSDictionary *dict in connects) {
        BSDPortConnectionDescription *desc = [BSDPortConnectionDescription connectionDescriptionWithDictionary:dict appendId:appendId];
        BSDBox *sender = self.boxes[desc.senderParentId];
        BSDBox *receiver = self.boxes[desc.receiverParentId];
        NSPredicate *r_predicate = [NSPredicate predicateWithFormat:@"%K = %@",@"portName",desc.receiverPortName];
        NSPredicate *s_predicate = [NSPredicate predicateWithFormat:@"%K = %@",@"portName",desc.senderPortName];
        NSArray *s = [sender.outletViews filteredArrayUsingPredicate:s_predicate];
        NSArray *r = [receiver.inletViews filteredArrayUsingPredicate:r_predicate];
        if (s && r) {
            BSDPortView *outletView = s.firstObject;
            BSDPortView *inletView = r.firstObject;
            desc.receiverPortView = inletView;
            [sender makeConnectionWithDescription:desc];
            [outletView addConnectionToPortView:inletView];
            [self boxDidMove:sender];
        }
        
    }
    
    if (loadBangs) {
        for (BSDLoadBang *myLB in loadBangs) {
            
            [myLB parentPatchFinishedLoading];
        }
    }
    
}

- (void)clearCurrentPatch
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
        
    }
    
    for (NSString *uniqueId in self.boxes.allKeys) {
        BSDBox *box = self.boxes[uniqueId];
        [box tearDown];
    }
    
    self.boxes = nil;
    self.graphBoxes = nil;
    self.connectionPaths = nil;
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.screenBox = nil;
    self.bezierPaths = nil;
    self.boxes = [NSMutableDictionary dictionary];
    self.graphBoxes = [NSMutableArray array];
    self.connectionPaths = [NSMutableArray array];
    //[self addCanvasBox];
    [self setNeedsDisplay];
}

#pragma mark - constructors


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
        _graphBoxes = [NSMutableArray array];
        _boxes = [NSMutableDictionary dictionary];
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.delegate = self;
        [self addGestureRecognizer:_doubleTap];
        _connectionPaths = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        kFocusPoint = CGPointMake(200, 200);
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleScreenDelegateNotification:) name:kScreenDelegateChannel
                                                  object:nil];
    }
    
    return self;
}

- (void)handleScreenDelegateNotification:(NSNotification *)notification
{
    BSDScreen *screen = notification.object;
    screen.delegate = self;
    for (BSDBox *box in self.boxes.allValues) {
        if ([[box.object objectId] hash] == [[screen objectId]hash]) {
            self.screenBox = (BSDGraphBox *)box;
            screen.delegate = self;
            return;
        }
    }
}

- (UIView *)canvasScreen
{
    return [self.delegate viewForCanvas:self];
}

- (void) makeBoxWithDescription:(BSDObjectDescription *)desc
{
    const char *class = [desc.boxClassName UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithDescription:");
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    [invocation setArgument:&desc atIndex:2];
    [invocation invoke];
    [instance setValue:self forKey:@"delegate"];
    [self.graphBoxes addObject:instance];
    self.boxes[[instance uniqueId]] = instance;
    [self addSubview:instance];
}

- (void)addCanvasBox
{
}

- (void)addGraphBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(0, 0, 140, 44);
    BSDGraphBox *graphBox = [[BSDGraphBox alloc]initWithFrame:rect];
    graphBox.delegate = self;
    graphBox.center = point;
    [self addSubview:graphBox];
    [self.graphBoxes addObject:graphBox];
    [self.boxes setValue:graphBox forKey:[graphBox uniqueId]];
}

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 72, 44);
    BSDNumberBox *numberBox = [[BSDNumberBox alloc]initWithFrame:rect];
    numberBox.delegate = self;
    numberBox.center = point;
    [self addSubview:numberBox];
    [self.graphBoxes addObject:numberBox];
    [self.boxes setValue:numberBox forKey:[numberBox uniqueId]];
}

- (void)addBangBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 60, 60);
    BSDBangControlBox *bangBox = [[BSDBangControlBox alloc]initWithFrame:rect];
    bangBox.delegate = self;
    bangBox.center = point;
    [self addSubview:bangBox];
    [self.graphBoxes addObject:bangBox];
    [self.boxes setValue:bangBox forKey:[bangBox uniqueId]];

}

- (void)addMessageBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 160, 44);
    BSDMessageBox *messageBox = [[BSDMessageBox alloc]initWithFrame:rect];
    messageBox.delegate = self;
    messageBox.center = point;
    [self addSubview:messageBox];
    [self.graphBoxes addObject:messageBox];
    [self.boxes setValue:messageBox forKey:[messageBox uniqueId]];

}

- (void)addCommentBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 200, 200);
    BSDCommentBox *commentBox = [[BSDCommentBox alloc]initWithFrame:rect];
    commentBox.delegate = self;
    commentBox.center = point;
    [self addSubview:commentBox];
    [self.graphBoxes addObject:commentBox];
    [self.boxes setValue:commentBox forKey:[commentBox uniqueId]];

}

- (void)addInletBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 80, 44);
    BSDInletBox *inletBox = [[BSDInletBox alloc]initWithFrame:rect];
    inletBox.delegate = self;
    inletBox.center = point;
    [self addSubview:inletBox];
    [self.graphBoxes addObject:inletBox];
    [self.boxes setValue:inletBox forKey:[inletBox uniqueId]];

}

- (void)addOutletBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 80, 44);
    BSDOutletBox *outletBox = [[BSDOutletBox alloc]initWithFrame:rect];
    outletBox.delegate = self;
    outletBox.center = point;
    [self addSubview:outletBox];
    [self.graphBoxes addObject:outletBox];
    [self.boxes setValue:outletBox forKey:[outletBox uniqueId]];
}

- (void)addBox:(id)sender type:(NSString *)type className:(NSString *)className args:(NSString *)args
{
}

- (CGPoint)positionFromFrame:(CGRect)frame
{
    return CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
}

- (void)describeYourself
{
    NSUInteger idx = 0;
    BSDPatchDescription *description = [[BSDPatchDescription alloc]initWithCanvasRect:self.bounds];
    for (BSDBox *box in self.graphBoxes) {
        CGPoint position = [self positionFromFrame:box.frame];
        box.tag = idx;
        [description addEntryType:box.boxClassString className:box.className args:box.argString position:position];
        idx++;
    }
    
    for (BSDBox *box in self.graphBoxes) {
        for (BSDPortView *portView in box.outletViews) {
            if (portView.connectedPortViews.count) {
                for (BSDPortView *receivingPort in portView.connectedPortViews) {
                    [description addConnectionSender:box.tag
                                              outlet:portView.tag
                                            receiver:receivingPort.superview.tag
                                               inlet:receivingPort.tag];
                }
            }
        }
    }
    
    [description print];
}

#pragma mark - Utility methods

- (CGPoint)optimalFocusPoint
{
    UIView *view = [self hitTest:kFocusPoint withEvent:0];
    if ([view isMemberOfClass:[BSDBox class]] || [view.superview isMemberOfClass:[BSDBox class]])
    {
        kFocusPoint.x += 50;
        kFocusPoint.y += 50;
    }
    
    return kFocusPoint;
}

#pragma mark UIView method overrides

- (void)drawRect:(CGRect)rect
{
    if (self.connectionOriginPoint && self.connectionDestinationPoint) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[self.connectionOriginPoint CGPointValue]];
        [path addLineToPoint:[self.connectionDestinationPoint CGPointValue]];
        [path setLineWidth:6];
        [[UIColor blackColor]setStroke];
        [path stroke];
    }
    
    if (self.connectionPaths != nil) {
        self.bezierPaths = nil;
        for (NSDictionary *vec in self.connectionPaths) {
            NSArray *points = vec[@"points"];
        //for (NSArray *points in self.connectionPaths) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:[points.firstObject CGPointValue]];
            [path addLineToPoint:[points.lastObject CGPointValue]];
            [path setLineWidth:4];
            [[UIColor blackColor]setStroke];
            [path stroke];
            if (!self.bezierPaths) {
                self.bezierPaths = [NSMutableDictionary dictionary];
            }
            
            self.bezierPaths[path] = vec[@"ports"];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
