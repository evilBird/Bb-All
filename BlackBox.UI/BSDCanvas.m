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
#import "BSDAbstractionBox.h"
@interface BSDCanvas ()<UIGestureRecognizerDelegate,BSDScreenDelegate>
{
    CGPoint kFocusPoint;
}


@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;
@property (nonatomic,strong)NSMutableDictionary *bezierPaths;

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
    
    for (BSDBox *box in self.graphBoxes) {
        if ([box isKindOfClass:[BSDGraphBox class]]
            || [box isKindOfClass:[BSDMessageBox class]]
            || [box isKindOfClass:[BSDNumberBox class]]) {
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
    for (BSDBox *box in self.graphBoxes) {
        if ([box isKindOfClass:[BSDGraphBox class]]
            || [box isKindOfClass:[BSDMessageBox class]]
            || [box isKindOfClass:[BSDNumberBox class]])
        {
            UITextField *textField = [box valueForKey:@"textField"];
            [textField setEnabled:YES];
        }
        
        [box setSelected:NO];

    }
    self.doubleTap.enabled = YES;
    [self.selectedBoxes removeAllObjects];
    self.selectedBoxes = nil;
    [self.copiedBoxes removeAllObjects];
    self.copiedBoxes = nil;
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
    
    self.copiedBoxes = self.selectedBoxes.mutableCopy;
    if (self.copiedBoxes) {
        self.editState = BSDCanvasEditStateContentCopied;
    }
}

- (void)deleteSelectedContent
{
    if (!self.selectedBoxes) {
        return;
    }
    
    for (BSDBox *box in self.selectedBoxes) {
        [box removeFromSuperview];
        [box tearDown];
    }
    
    [self.selectedBoxes removeAllObjects];
    self.selectedBoxes = nil;
    [self boxDidMove:nil];

    self.editState = BSDCanvasEditStateEditing;
}

- (void)pasteSelectedContent
{
    if (!self.copiedBoxes){
        return;
    }
    
    NSString *desc = [self describeBoxes:self.copiedBoxes];
    NSArray *copied = [self parseDescription:desc];
    [self.graphBoxes addObjectsFromArray:copied];
}

- (NSString *)genericCanvasDescriptionName:(NSString *)string
{
    NSString *entry = [NSString stringWithFormat:@"#N canvas 0 0 %@ %@ %@;\n",@(self.bounds.size.width),@(self.bounds.size.height),string];
    return entry;
}

- (void)encapsulatedCopiedContentWithName:(NSString *)name
{
    NSString *desc = [self describeBoxes:self.copiedBoxes];
    NSString *genericCanvas = [self genericCanvasDescriptionName:name];
    NSString *description = [genericCanvas stringByAppendingString:desc];
    BSDCanvas *canvas = [[BSDCanvas alloc]initWithDescription:description];
    if (!self.subcanvases) {
        self.subcanvases  = [NSMutableArray array];
    }
    
    [self.subcanvases addObject:canvas];
    BSDAbstractionBox *new = [self newAbstractionBox:name atPoint:kFocusPoint];
    new.canvas = canvas;
    [self.graphBoxes addObject:new];
    //[self addSubview:canvas];
    
    /*
    NSMutableDictionary *toEncapsulate = [self.copiedBoxes mutableCopy];
    [self.delegate saveAbstraction:toEncapsulate withName:name];
    [self addGraphBoxAtPoint:kFocusPoint];
    BSDGraphBox *box = self.graphBoxes.lastObject;
    [box createObjectWithName:@"BSDCompiledPatch" arguments:@[name]];
    [self deleteSelectedContent];
    */
}

- (NSString *)canvasId
{
    return [NSString stringWithFormat:@"%@",self];
}

#pragma mark - touch handling methods
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
        self.selectedBoxes = [NSMutableArray array];
    }
    if (toSelect.selected) {
        [self.selectedBoxes addObject:toSelect];
    }else{
        if ([self.selectedBoxes containsObject:toSelect]) {
            [self.selectedBoxes removeObject:toSelect];
        }
    }
    
    if (self.selectedBoxes.count > 0) {
        self.editState = BSDCanvasEditStateContentSelected;
    }
}

- (void)handleDoubleTap:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    kFocusPoint = loc;
    UIView *theView = [self hitTest:loc withEvent:UIEventTypeTouches];
    if ([theView isKindOfClass:[BSDBox class]]
        || [theView.superview isKindOfClass:[BSDBox class]]
        || [theView isKindOfClass:[UITextField class]]
        || [theView isKindOfClass:[BSDTextField class]])
    {
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
        BSDBox *oldBox = (BSDBox *)pv.superview;
        BSDBox *newBox = (BSDBox *)newConnection.superview;
        [oldBox connectOutlet:pv.tag toInlet:newConnection.tag inBox:newBox];
        [newBox setSelectedPortView:nil];
        [oldBox setSelectedPortView:nil];
    }
    
    [sender setSelectedPortView:nil];
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.connectionPaths = nil;
    self.bezierPaths = nil;
    self.connectionPaths = [NSMutableArray arrayWithArray:[self allConnections]];
    kFocusPoint = point;
    [self setNeedsDisplay];
    
    for (BSDBox *box in self.graphBoxes) {
        [box setSelectedPortView:nil];
    }
}

- (void)boxDidMove:(id)sender
{
    self.connectionPaths = nil;
    self.connectionPaths = [NSMutableArray arrayWithArray:[self allConnections]];
    [self setNeedsDisplay];
}

- (UIView *)displayViewForBox:(id)sender
{
    return [self.delegate viewForCanvas:self];
}

#pragma mark - manage connections

- (NSArray *)allConnections
{
    NSMutableArray *temp = [NSMutableArray array];
    for (BSDBox *gb in self.graphBoxes) {
        NSArray *connections = [gb connectionVectors];
        if (connections) {
            [temp addObjectsFromArray:connections];
        }
    }
    return temp;
}

#pragma mark - Patch management

- (void)clearCurrentPatch
{
    for (BSDBox *box in self.graphBoxes) {
        [box tearDown];
        [box removeFromSuperview];
    }
    
    self.graphBoxes = nil;
    self.connectionPaths = nil;
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.bezierPaths = nil;
    self.connectionPaths = [NSMutableArray array];
    [self setNeedsDisplay];
}

#pragma mark - constructors
- (instancetype)initWithDescription:(NSString *)desc
{
    NSArray *entries = [desc componentsSeparatedByString:@";\n"];
    CGRect frame = [BSDCanvas frameWithEntry:entries.firstObject];
    self = [self initWithFrame:frame];
    if (self) {
        [self loadPatchWithDescription:desc];
    }
    
    return self;
}

- (void)loadPatchWithDescription:(NSString *)description
{
    [self clearCurrentPatch];
    NSArray *objs = [self parseDescription:description];
    if (!self.graphBoxes) {
        self.graphBoxes = [NSMutableArray array];
    }
    
    [self.graphBoxes addObjectsFromArray:objs];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
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
}

- (UIView *)canvasScreen
{
    return [self.delegate viewForCanvas:self];
}

- (void)addGraphBoxAtPoint:(CGPoint)point
{
    BSDGraphBox *box = [self newGraphBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDGraphBox *)newGraphBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(0, 0, 140, 44);
    BSDGraphBox *graphBox = [[BSDGraphBox alloc]initWithFrame:rect];
    graphBox.delegate = self;
    graphBox.center = point;
    [self addSubview:graphBox];
    return graphBox;
}

- (BSDAbstractionBox *)newAbstractionBox:(NSString *)name atPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(0, 0, 140, 44);
    BSDAbstractionBox *box = [[BSDAbstractionBox alloc]initWithFrame:rect];
    box.delegate = self;
    box.center = point;
    box.textField.text = [NSString stringWithFormat:@"Bb %@",name];
    [self addSubview:box];
    return box;
}

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    BSDNumberBox *box = [self newNumberBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDNumberBox *)newNumberBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 72, 44);
    BSDNumberBox *numberBox = [[BSDNumberBox alloc]initWithFrame:rect];
    numberBox.delegate = self;
    numberBox.center = point;
    [self addSubview:numberBox];
    return numberBox;
}

- (void)addBangBoxAtPoint:(CGPoint)point
{
    BSDBangControlBox *box = [self newBangBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDBangControlBox *)newBangBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 60, 60);
    BSDBangControlBox *bangBox = [[BSDBangControlBox alloc]initWithFrame:rect];
    bangBox.delegate = self;
    bangBox.center = point;
    [self addSubview:bangBox];
    
    return bangBox;
}

- (void)addMessageBoxAtPoint:(CGPoint)point
{
    BSDMessageBox *box = [self newMessageBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDMessageBox *)newMessageBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 160, 44);
    BSDMessageBox *messageBox = [[BSDMessageBox alloc]initWithFrame:rect];
    messageBox.delegate = self;
    messageBox.center = point;
    [self addSubview:messageBox];
    return messageBox;
}

- (void)addCommentBoxAtPoint:(CGPoint)point
{
    BSDCommentBox *box = [self newCommentBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDCommentBox *)newCommentBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 200, 200);
    BSDCommentBox *commentBox = [[BSDCommentBox alloc]initWithFrame:rect];
    commentBox.delegate = self;
    commentBox.center = point;
    [self addSubview:commentBox];
    return commentBox;
}

- (void)addInletBoxAtPoint:(CGPoint)point
{
    BSDInletBox *box = [self newInletBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDInletBox *)newInletBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 80, 44);
    BSDInletBox *inletBox = [[BSDInletBox alloc]initWithFrame:rect];
    inletBox.delegate = self;
    inletBox.center = point;
    [self addSubview:inletBox];
    return inletBox;
}

- (void)addOutletBoxAtPoint:(CGPoint)point
{
    BSDOutletBox *box = [self newOutletBoxAtPoint:point];
    [self addGraphBox:box];
}

- (BSDOutletBox *)newOutletBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 80, 44);
    BSDOutletBox *outletBox = [[BSDOutletBox alloc]initWithFrame:rect];
    outletBox.delegate = self;
    outletBox.center = point;
    [self addSubview:outletBox];
    return outletBox;
}

- (void)addGraphBox:(BSDBox *)box
{
    if (!self.graphBoxes) {
        self.graphBoxes = [NSMutableArray array];
    }
    [self.graphBoxes addObject:box];
    [box initializeWithText:nil];
}

- (NSString *)stringDescription
{
    NSArray *boxes = [NSArray arrayWithArray:self.graphBoxes];
    NSString *description = [self describeBoxes:boxes];
    return [NSString stringWithString:description];
}

- (NSString *)describeBoxes:(NSArray *)boxes
{
    NSUInteger idx = 0;
    BSDPatchDescription *description = [[BSDPatchDescription alloc]initWithCanvasRect:self.bounds];
    for (BSDBox *box in boxes) {
        CGPoint position = [self positionFromFrame:box.frame];
        box.tag = idx;
        if ([box isKindOfClass:[BSDAbstractionBox class]]) {
            BSDAbstractionBox *abstraction = (BSDAbstractionBox *)box;
            BSDCanvas *canvas = abstraction.canvas;
            NSString *desc = [canvas stringDescription];
            NSString *name = nil;
            [description addPatchDescription:desc name:name frame:box.frame];
        }else{
            [description addEntryType:box.boxClassString className:box.className args:box.argString position:position];
        }
        idx++;
    }
    
    for (BSDBox *box in boxes) {
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
    
    NSString *result = [description getDescription];
    NSLog(@"%@",result);
    return result;
}

- (NSMutableArray *)parseDescription:(NSString *)desc
{
    NSMutableArray *temp = nil;
    NSArray *entries = [self entriesInDescription:desc];
    NSInteger idx = 0;
    for (NSString *entry in entries) {
        NSArray *components = [self componentsOfEntry:entry];
        NSString *action = components[0];
        if ([action isEqualToString:@"#X"]) {
            NSString *type = components[1];
            if ([type isEqualToString:@"connection"]) {
                
                NSString *sender = components[2];
                NSString *outlet = components[3];
                NSString *receiver = components[4];
                NSString *inlet = components[5];
                
                BSDBox *s = temp[sender.integerValue];
                BSDBox *r = temp[receiver.integerValue];
                NSInteger o = outlet.integerValue;
                NSInteger i = inlet.integerValue;
                [s connectOutlet:o toInlet:i inBox:r];
                
            }else{
                
                BSDBox *box = [self makeBoxWithEntry:entry components:components];
                box.tag = idx;
                idx++;
                
                if (!temp){
                    temp = [NSMutableArray array];
                }
                [temp addObject:box];
            }
        }else if ([action isEqualToString:@"#N"]){
            NSString *type = components[1];
            if ([type isEqualToString:@"canvas"]) {
                BSDBox *box = [self makeBoxWithEntry:entry components:components];
                box.tag = idx;
                idx++;
                if (!temp) {
                    temp = [NSMutableArray array];
                }
                [temp addObject:box];
            }

        }
    }
    
    return temp;
}

- (BSDBox *)makeBoxWithEntry:(NSString *)entry components:(NSArray *)components
{
    NSString *type = components[1];
    NSString *x = components[2];
    NSString *y = components[3];
    CGPoint point = CGPointMake(x.floatValue, y.floatValue);
    NSString *className = components[4];
    NSString *classAndArgs = nil;
    BSDBox *result = nil;
    
    NSUInteger typeHash = [type hash];
    if (typeHash ==[@"BSDGraphBox" hash]) {
        result = [self newGraphBoxAtPoint:point];
            NSRange range = [entry rangeOfString:className];
            classAndArgs = [entry substringFromIndex:range.location];
    }else if (typeHash == [@"BSDMessageBox" hash]){
        result = [self newMessageBoxAtPoint:point];
        if (components.count > 5) {
            NSRange range = [entry rangeOfString:components[5]];
            classAndArgs = [entry substringFromIndex:range.location];
        }
    }else if (typeHash == [@"BSDNumberBox" hash]){
        result = [self newNumberBoxAtPoint:point];
    }else if (typeHash == [@"BSDCommentBox" hash]){
        result = [self newCommentBoxAtPoint:point];
    }else if (typeHash == [@"BSDInletBox" hash]){
        result = [self newInletBoxAtPoint:point];
    }else if (typeHash == [@"BSDOutletBox" hash]){
        result = [self newOutletBoxAtPoint:point];
    }else if (typeHash == [@"BSDBangControlBox" hash]){
        result = [self newBangBoxAtPoint:point];
    }else if (typeHash == [@"canvas" hash]){
        if (components.count > 6) {
            NSRange range = [entry rangeOfString:components[6]];
            classAndArgs = [entry substringFromIndex:range.location];
        }
        
        result = [self newAbstractionBox:components[6] atPoint:point];
        BSDCanvas *canvas = [[BSDCanvas alloc]initWithDescription:classAndArgs];
        if (!self.subcanvases) {
            self.subcanvases  = [NSMutableArray array];
        }
        
        [self.subcanvases addObject:canvas];
        [(BSDAbstractionBox *)result setCanvas:canvas];
    }
    
    [result initializeWithText:classAndArgs];
    
    NSLog(@"class and args: %@",classAndArgs);
    
    return result;
}

- (NSArray *)entriesInDescription:(NSString *)desc
{
    NSArray *canvases = [desc componentsSeparatedByString:@";\n#N"];
    if (canvases) {
        NSString *c = canvases[1];
        
        //NSArray *cd = [c stringByReplacingCharactersInRange:<#(NSRange)#> withString:<#(NSString *)#>];
        
        //return [self entriesInDescription:];
    }
    
    return [desc componentsSeparatedByString:@";\n"];
}

- (NSArray *)componentsOfEntry:(NSString *)entry
{
    return [entry componentsSeparatedByString:@" "];
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

- (CGPoint)positionFromFrame:(CGRect)frame
{
    return CGPointMake(frame.origin.x + frame.size.width * 0.5, frame.origin.y + frame.size.height * 0.5);
}

+ (CGRect)frameWithEntry:(NSString *)entry
{
    NSArray *components = [entry componentsSeparatedByString:@" "];
    NSString *x = components[2];
    NSString *y = components[3];
    NSString *width = components[4];
    NSString *height = components[5];
    return CGRectMake(x.floatValue, y.floatValue, width.floatValue, height.floatValue);
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
