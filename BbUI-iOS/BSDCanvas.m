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
#import "BSDPatchCompiler.h"
#import "BSDPort.h"
#import "BSDHSlider.h"
#import "BSDActionPopup.h"
#import "BSDPatchManager.h"
#import "BSDPrint.h"

@interface BSDCanvas ()<UIGestureRecognizerDelegate,BSDScreenDelegate,BSDPortDelegate>
{
    CGPoint kFocusPoint;
}


@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;
@property (nonatomic,strong)NSMutableDictionary *bezierPaths;
@property (nonatomic,strong)NSMutableArray *connectionBezierPaths;
@property (nonatomic,strong)NSMutableArray *connectedPorts;
@property (nonatomic,strong)NSString *pasteBoard;
@property (nonatomic,strong)NSValue *previousTranslation;

@property (nonatomic,strong)BSDObject *testObject;

@end

@implementation BSDCanvas

#pragma mark - edit state management

- (void)updateCompiledInstancesWithName:(NSString *)name
{
    
}

- (void)loadBang
{
    if (!self.graphBoxes) {
        return;
    }
    
    //then everything else
    for (BSDBox *box in self.graphBoxes) {
        id object = box.object;
        if (![object isKindOfClass:[BSDCanvas class]] && ![object isKindOfClass:[BSDCompiledPatch class]]) {
            [object loadBang];
        }
    }
    
    //depth first
    for (BSDBox *box in self.graphBoxes) {
        id object = box.object;
        if ([object isKindOfClass:[BSDCanvas class]]) {
            [object loadBang];
        }else if ([object isKindOfClass:[BSDCompiledPatch class]]){
            [[(BSDCompiledPatch *)object canvas]loadBang];
        }
    }
}

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
}

- (void)copySelectedContent
{
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    NSArray *selectedBoxes = [self.graphBoxes filteredArrayUsingPredicate:selected];
    if (!selectedBoxes) {
        return;
    }
    
    if (self.pasteBoard) {
        self.pasteBoard = nil;
    }
    
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    NSString *boxes = [compiler saveBoxes:selectedBoxes];
    NSString *connections = [compiler saveConnectionsBetweenBoxes:selectedBoxes];
    NSString *boxesAndConnections = [NSString stringWithFormat:@"%@%@",boxes,connections];
    self.pasteBoard = boxesAndConnections;
    if (self.pasteBoard) {
        self.editState = BSDCanvasEditStateContentCopied;
    }
}

- (void)deleteSelectedContent
{
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    NSArray *selectedBoxes = [self.graphBoxes filteredArrayUsingPredicate:selected];
    if (!selectedBoxes) {
        return;
    }
    
    for (BSDBox *box in selectedBoxes) {
        [self.graphBoxes removeObject:box];
        box.delegate = nil;
        [box removeFromSuperview];
        if ([box isKindOfClass:[BSDInletBox class]]) {
            BSD2WayPort *port = box.object;
            NSInteger index = [self.inlets indexOfObject:port.inlets.firstObject];
            if (self.parentCanvas) {
                [self.parentCanvas removeInletViewAtIndex:index
                                            fromSubcanvas:self];
            }
            [self.inlets removeObject:port.inlets.firstObject];
        }else if ([box isKindOfClass:[BSDOutletBox class]]){
            BSD2WayPort *port = box.object;
            NSInteger index = [self.outlets indexOfObject:port.outlets.firstObject];
            if (self.parentCanvas) {
                [self.parentCanvas removeOutletViewAtIndex:index fromSubcanvas:self];
            }
            
            [self.outlets removeObject:port.outlets.firstObject];
        }
        
        [box tearDown];
    }
    
    [self boxDidMove:nil];
    self.editState = BSDCanvasEditStateEditing;
}

- (void)removeInletViewAtIndex:(NSInteger)index fromSubcanvas:(BSDCanvas *)canvas
{
    BSDBox *box = [self boxForCanvas:canvas];
    if (!box || index >= box.inletViews.count) {
        return;
    }
    
    BSDPortView *toremove = box.inletViews[index];
    [toremove removeFromSuperview];
    [toremove tearDown];
    [self boxDidMove:box];
}

- (void)removeOutletViewAtIndex:(NSInteger)index fromSubcanvas:(BSDCanvas *)canvas
{
    BSDBox *box = [self boxForCanvas:canvas];
    if (!box || index >= box.outletViews.count) {
        return;
    }
    
    BSDPortView *toremove = box.outletViews[index];
    [toremove removeFromSuperview];
    [toremove tearDown];
    [self boxDidMove:box];
}

- (BSDBox *)boxForCanvas:(BSDCanvas *)canvas
{
    for (BSDBox *box in self.graphBoxes) {
        if ([box isKindOfClass:[BSDAbstractionBox class]] && box.object == canvas) {
            return box;
        }
    }
    
    return nil;
}

- (void)pasteSelectedContent
{
    if (!self.pasteBoard){
        return;
    }
    
    BSDPatchCompiler *compiler = [[BSDPatchCompiler alloc]initWithArguments:nil];
    NSArray *pasted = [compiler restoreBoxesWithText:self.pasteBoard];
    
    for (BSDBox *box in pasted) {
        box.delegate = self;
        CGPoint center = [self positionFromFrame:box.frame];
        center.x += 100;
        box.center = center;
        [self addSubview:box];
        if (!self.graphBoxes){
            self.graphBoxes = [NSMutableArray array];
        }
        [self.graphBoxes addObject:box];
        
        if ([box isKindOfClass:[BSDInletBox class]]) {
            BSD2WayPort *port = [box object];
            if (!self.inlets) {
                self.inlets = [NSMutableArray array];
            }
            [self.inlets addObject:port.inlets.firstObject];
        }else if ([box isKindOfClass:[BSDOutletBox class]]){
            BSD2WayPort *port = [box object];
            if (!self.outlets) {
                self.outlets = [NSMutableArray array];
            }
            [self.outlets addObject:port.outlets.firstObject];
        }else if ([box isKindOfClass:[BSDAbstractionBox class]]){
            BSDCanvas *canvas = box.object;
            canvas.parentCanvas = self;
            canvas.delegate = self.delegate;
        }
    }

    [self boxDidMove:nil];
    
    if (self.pasteBoard) {
        self.editState = BSDCanvasEditStateContentCopied;
    }

}

- (NSString *)genericCanvasDescriptionName:(NSString *)string
{
    return [self.delegate emptyCanvasDescriptionName:string];
}

- (void)encapsulatedCopiedContentWithName:(NSString *)name
{
    if (!self.pasteBoard) {
        return;
    }
    
    NSString *canvasDesc = [self genericCanvasDescriptionName:name];
    NSString *full = [NSString stringWithFormat:@"%@%@",canvasDesc,self.pasteBoard];
    [self.delegate saveCanvas:nil description:full name:name];
    BSDBox *box = [self newGraphBoxAtPoint:kFocusPoint];
    box.argString = name;
    box.className = @"BSDCompiledPatch";
    [self addGraphBox:box initialize:YES arg:name];

}

- (void)tearDown
{
    [self clearCurrentPatch];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[BSDCanvas class]]) {
        return NO;
    }
    
    return [self hash] == [object hash];
}

- (NSUInteger)hash
{
    return [self.canvasId hash];
}

- (NSString *)canvasId
{
    return [NSString stringWithFormat:@"%@",self.instanceId];
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
        [self deleteConnectionsAtPoint:loc];
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

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    NSArray *selectedBoxes = [self.graphBoxes filteredArrayUsingPredicate:predicate];
    
    if (selectedBoxes > 0) {
        self.editState = BSDCanvasEditStateContentSelected;
    }
}

- (void)handleDoubleTap:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    kFocusPoint = loc;
    UIView *theView = [self hitTest:loc withEvent:UIEventTypeTouches];
    /*
    if ([theView isKindOfClass:[BSDAbstractionBox class]]) {
        [self showActionPopupForBox:(BSDBox *)theView];
        return;
    }
    
    if ([theView.superview isKindOfClass:[BSDAbstractionBox class]]) {
        [self showActionPopupForBox:(BSDBox *)theView.superview];
        return;
    }
    */
    if ([theView isKindOfClass:[BSDBox class]]
        || [theView.superview isKindOfClass:[BSDBox class]]
        || [theView isKindOfClass:[UITextField class]]
        || [theView isKindOfClass:[BSDTextField class]])
    {
        BSDBox *box = nil;
        if ([theView isKindOfClass:[BSDBox class]]) {
            box = (BSDBox *)theView;
        }else if ([theView.superview isKindOfClass:[BSDBox class]]){
            box = (BSDBox *)theView.superview;
        }
        
        NSArray *actions = [self actionsForBox:box];
        
        
        if (actions) {
            [self showActionPopupForBox:box withActions:actions];
        }
        
        return;
    }
    
    [self addGraphBoxAtPoint:loc];
    
}

- (void)showActionPopupForBox:(BSDBox *)box withActions:(NSArray *)actions
{
    CGPoint anchor;
    anchor.y = CGRectGetMinY(box.frame);
    anchor.x = CGRectGetMidX(box.frame);
    __weak BSDCanvas *weakself = self;
    [BSDActionPopup showPopupWithActions:actions
                          associatedView:box
                             anchorPoint:anchor
                              completion:^(NSInteger selectedIndex) {
                                  [weakself doAction:selectedIndex withBox:box];
                              }];

}

- (void)doAction:(NSInteger)action withBox:(BSDBox *)box
{
    switch (action) {
        case 0:
            [self openGraphBox:(BSDGraphBox *)box];
            break;
            case 1:
            [self openHelpPatchForBox:box];
            break;
            case 2:
            [self testBox:box];
            break;
        default:
            break;
    }
}

- (void)openHelpPatchForBox:(BSDBox *)box
{
    NSString *patchName = nil;
    NSString *helpPatchName = nil;
    if ([box.object isKindOfClass:[BSDCompiledPatch class]]) {
        patchName = [box argString];
        helpPatchName = [patchName stringByAppendingPathExtension:@"help"];
    }else{
        patchName = [box className];
        helpPatchName = [@"Help" stringByAppendingPathExtension:patchName];
    }
    
    BSDCompiledPatch *helpPatch = [[BSDCompiledPatch alloc]initWithArguments:helpPatchName];
    [self.delegate showCanvasForCompiledPatch:helpPatch];
}

- (void)testBox:(BSDBox *)box
{
    NSString *patchName = [box argString];
    NSString *testPatchName = [patchName stringByAppendingPathExtension:@"test"];
    self.testObject = [[BSDCompiledPatch alloc]initWithArguments:@[testPatchName,patchName]];
    [[(BSDCompiledPatch *)self.testObject canvas]loadBang];
    [self.testObject.inlets.firstObject input:[BSDBang bang]];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.testObject tearDown];
        self.testObject = nil;
    });

}

- (NSArray *)actionsForBox:(BSDBox *)box
{
    NSMutableArray *result = nil;
    
    if ([box.object isKindOfClass:[BSDCompiledPatch class]]) {
        if (!result) {
            result = [NSMutableArray array];
        }
        
        [result addObject:@"open"];
        NSString *argString = box.argString;
        NSString *testPatchName = [argString stringByAppendingPathExtension:@"test"];
        NSString *helpPatchName = [argString stringByAppendingPathExtension:@"help"];
        id help = [[BSDPatchManager sharedInstance]getPatchNamed:helpPatchName];
        if (help != nil) {
            [result addObject:@"help"];
        }
        
        id test = [[BSDPatchManager sharedInstance]getPatchNamed:testPatchName];
        if (test != nil) {
            [result addObject:@"test"];
        }
        
        [result addObject:@"cancel"];
        
        return result;
    }
    
    NSString *objectClass = NSStringFromClass([box.object class]);
    NSString *helpPatchName = [@"Help" stringByAppendingPathExtension:objectClass];
    id helpPatch = [[BSDPatchManager sharedInstance]getPatchNamed:helpPatchName];
    if (helpPatch) {
        if (!result) {
            result = [NSMutableArray array];
        }
        
        [result addObject:@"help"];
        [result addObject:@"cancel"];
    }
    
    return result;
    return nil;
}

- (void)openAbstraction:(BSDAbstractionBox *)abs
{
    BSDCanvas *canvas = [abs object];
    canvas.delegate = self.delegate;
    canvas.parentCanvas = self;
    [self.delegate setCurrentCanvas:canvas];
    UIButton *button = [UIButton new];
    [button setTitle:@"X" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(8, 8, 44, 44)];
    [canvas addSubview:button];
    [button addTarget:self action:@selector(closeCanvas:) forControlEvents:UIControlEventTouchUpInside];
    [canvas addSubview:button];
    [self addSubview:canvas];
    [canvas boxDidMove:nil];
}

- (void)openGraphBox:(BSDGraphBox *)graphBox
{
    NSArray *args = graphBox.creationArguments;
    NSString *patchName = args.firstObject;
    BSDCompiledPatch *patch = graphBox.object;
    CGRect frame = self.bounds;
    frame.origin = CGPointMake(0, 0);
    patch.canvas.frame = frame;
    patch.canvas.name = patchName;
    [self.delegate showCanvasForCompiledPatch:patch];
    NSValue *rect = [NSValue wrapRect:patch.canvas.frame];
    NSLog(@"rect: %@",rect);
}

- (void)closeCanvas:(UIButton *)sender
{
    BSDCanvas *canvas = (BSDCanvas *)sender.superview;
    __weak BSDCanvas *weakself = self;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         canvas.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             
                             [canvas removeFromSuperview];
                             [sender removeFromSuperview];
                             
                             [weakself.delegate setCurrentCanvas:weakself];
                             BSDBox *box = [weakself boxForCanvas:canvas];
                             if (!box) {
                                 return;
                             }
                             
                             if (box.inletViews.count < canvas.inlets.count) {
                                 [box updateInletViews];
                             }
                             
                             if (box.outletViews.count < canvas.outlets.count) {
                                 [box updateOutletViews];
                             }
                         });
                     }];
    
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
        BSDBox *oldBox = (BSDBox *)pv.delegate;
        BSDBox *newBox = (BSDBox *)newConnection.delegate;
        NSInteger oi = [oldBox.outletViews indexOfObject:pv];
        NSInteger ii = [newBox.inletViews indexOfObject:newConnection];
        [oldBox connectOutlet:oi toInlet:ii inBox:newBox];
        [newBox setSelectedPortView:nil];
        [oldBox setSelectedPortView:nil];
    }
    
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
    
    self.previousTranslation = nil;
}

- (void)boxDidMove:(id)sender
{
    self.connectionPaths = nil;
    if (sender != nil && [sender isKindOfClass:[BSDBox class]] && self.editState > 1 && [sender selected] == 1) {
        NSValue *trans = [sender translation];
        CGPoint translation;
        if (self.previousTranslation != nil) {
            CGPoint pt = self.previousTranslation.CGPointValue;
            CGPoint tt = trans.CGPointValue;
            translation.x = tt.x - pt.x;
            translation.y = tt.y - pt.y;
        }else{
            translation = trans.CGPointValue;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
        NSArray *selectedBoxes = [self.graphBoxes filteredArrayUsingPredicate:predicate];
        NSMutableArray *selectedCopy = selectedBoxes.mutableCopy;
        if ([selectedCopy containsObject:sender]) {
            [selectedCopy removeObject:sender];
        }
        
        for (BSDBox *box in selectedCopy) {
            CGPoint center = box.center;
            center.x += translation.x;
            center.y += translation.y;
            box.center = center;
        }
        
        self.previousTranslation = [NSValue wrapPoint:trans.CGPointValue];
    }
    
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

- (void)deleteConnectionsAtPoint:(CGPoint)point
{
    if (self.connectionBezierPaths) {
        for (UIBezierPath *path in self.connectionBezierPaths) {
            BOOL hit = [self bezierPath:path containsPoint:point];
            if (hit) {
                NSInteger idx = [self.connectionBezierPaths indexOfObject:path];
                NSDictionary *ports = self.connectedPorts[idx];
                BSDPortView *sender = ports[@"sender"];
                BSDPortView *receiver = ports[@"receiver"];
                [self removeConnectionFromSender:sender toReciever:receiver];
            }
        }
    }
}

- (void)removeConnectionFromSender:(BSDPortView *)sender toReciever:(BSDPortView *)receiver
{
    BSDBox *senderBox = (BSDBox *)sender.superview;
    BSDBox *receiverBox = (BSDBox *)receiver.superview;
    BSDObject *senderObj = senderBox.object;
    BSDObject *receiverObj = receiverBox.object;
    NSInteger senderPortIdx = [senderBox.outletViews indexOfObject:sender];
    NSInteger receiverPortIdx = [receiverBox.inletViews indexOfObject:receiver];
    BSDOutlet *outlet = senderObj.outlets[senderPortIdx];
    BSDInlet *inlet = receiverObj.inlets[receiverPortIdx];
    [outlet disconnectFromInlet:inlet];
    [sender.connectedPortViews removeObject:receiver];
    
    [self boxDidMove:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint loc = [touches.allObjects.lastObject locationInView:self];
    kFocusPoint = loc;
}

- (BOOL)bezierPath:(UIBezierPath *)path containsPoint:(CGPoint)point
{
    CGPathRef pathRef = path.CGPath;
    CGRect boundingRect = CGPathGetBoundingBox(pathRef);
    return CGRectContainsPoint(boundingRect, point);
}

#pragma mark - Patch management

- (void)clearCurrentPatch
{
    for (BSDBox *box in self.graphBoxes) {
        [box tearDown];
        [box removeFromSuperview];
        if ([box isKindOfClass:[BSDInletBox class]]) {
            BSD2WayPort *port = box.object;
            [self.inlets removeObject:port.inlets.firstObject];
        }else if ([box isKindOfClass:[BSDOutletBox class]]){
            BSD2WayPort *port = box.object;
            [self.outlets removeObject:port.outlets.firstObject];
        }
    }
    
    [self.graphBoxes removeAllObjects];
    [self.inlets removeAllObjects];
    [self.outlets removeAllObjects];
    self.parentCanvas = nil;
    self.inlets = nil;
    self.outlets = nil;
    self.delegate = nil;
    self.connectionPaths = nil;
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.bezierPaths = nil;
    self.connectionPaths = [NSMutableArray array];
    [self setNeedsDisplay];
}

#pragma mark - constructors

- (instancetype)initWithArguments:(id)arguments
{
    return [self initWithDescription:arguments];
}

- (instancetype)initWithDescription:(NSString *)desc
{
    NSArray *entries = [desc componentsSeparatedByString:@";\n"];
    CGRect frame = [BSDCanvas frameWithEntry:entries.firstObject];
    self = [self initWithFrame:frame];
    if (self) {
        NSArray *components = [entries.firstObject componentsSeparatedByString:@" "];
        self.name = components[6];
        if (components.count > 7) {
            NSLog(@"there are %@ creation args in canvas %@",@(components.count - 7),self.name);
        }
    }
    return self;
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
    }
    
    return self;
}

- (void)addGraphBoxAtPoint:(CGPoint)point
{
    BSDGraphBox *box = [self newGraphBoxAtPoint:point];
    [self addGraphBox:box initialize:NO arg:nil];
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
    box.textField.text = [NSString stringWithFormat:@"bb %@",name];
    [self addSubview:box];
    return box;
}

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    BSDNumberBox *box = [self newNumberBoxAtPoint:point];
    [self addGraphBox:box initialize:YES arg:nil];
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

- (void)addHSliderBoxAtPoint:(CGPoint)point
{
    BSDHSlider *slider = [self newHSliderBoxAtPoint:point];
    [self addGraphBox:slider initialize:YES arg:nil];
}

- (BSDHSlider *)newHSliderBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 200, 36);
    BSDHSlider *slider = [[BSDHSlider alloc]initWithFrame:rect];
    slider.delegate = self;
    slider.center = point;
    [self addSubview:slider];
    return slider;
}

- (void)addBangBoxAtPoint:(CGPoint)point
{
    BSDBangControlBox *box = [self newBangBoxAtPoint:point];
    [self addGraphBox:box initialize:YES arg:nil];
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
    [self addGraphBox:box initialize:YES arg:nil];
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
    [self addGraphBox:box initialize:YES arg:nil];
}

- (BSDCommentBox *)newCommentBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 320, 200);
    BSDCommentBox *commentBox = [[BSDCommentBox alloc]initWithFrame:rect];
    commentBox.delegate = self;
    commentBox.center = point;
    [self addSubview:commentBox];
    return commentBox;
}

- (void)addInletBoxAtPoint:(CGPoint)point
{
    BSDInletBox *box = [self newInletBoxAtPoint:point];
    [self addGraphBox:box initialize:YES arg:nil];
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
    [self addGraphBox:box initialize:YES arg:nil];
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

- (void)addGraphBox:(BSDBox *)box initialize:(BOOL)init arg:(NSString *)arg
{
    if (!self.graphBoxes) {
        self.graphBoxes = [NSMutableArray array];
    }
    NSInteger count = self.graphBoxes.count;
    box.tag = count;
    box.canvasId = self.canvasId;
    box.canvasCreationArgs = self.creationArgArray.mutableCopy;
    
    [self.graphBoxes addObject:box];
    
    if (init) {
        [box initializeWithText:arg];
    }
    
    if ([box isKindOfClass:[BSDInletBox class]]) {
        BSD2WayPort *port = box.object;
        if (!self.inlets) {
            self.inlets = [NSMutableArray array];
        }
        [self.inlets addObject:port.inlets.firstObject];

    }else if ([box isKindOfClass:[BSDOutletBox class]]){
        BSD2WayPort *port = box.object;
        if (!self.outlets) {
            self.outlets = [NSMutableArray array];
        }
        [self.outlets addObject:port.outlets.firstObject];
    }
}

- (void)updateInletViewsForCanvas:(BSDCanvas *)canvas
{
    BSDBox *box = [self boxForCanvas:canvas];
    if (!box) {
        return;
    }
    
    [box updateInletViews];
    [self boxDidMove:box];
}

- (void)updateOutletViewsForCanvas:(BSDCanvas *)canvas
{
    BSDBox *box = [self boxForCanvas:canvas];
    if (!box) {
        return;
    }
    
    [box updateOutletViews];
    [self boxDidMove:box];
}

- (void)updatePortViewsForCanvas:(BSDCanvas *)canvas
{
    if (!canvas) {
        return;
    }
    
    BSDBox *box = [self boxForCanvas:canvas];
    if (!box) {
        return;
    }
    [box updateInletViews];
    [box updateOutletViews];
    [self boxDidMove:box];
}

- (NSString *)objectId
{
    return [self canvasId];
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
        [path addLineToPoint:[self.connectionOriginPoint CGPointValue]];
        [path closePath];
        [path setLineWidth:6];
        [[UIColor blackColor]setStroke];
        [[UIColor blackColor]setFill];
        [path stroke];
        [path closePath];
        [path fill];
    }
    
    self.connectionBezierPaths = nil;
    self.connectedPorts = nil;
    
    if (self.connectionPaths != nil) {
        self.bezierPaths = nil;
        for (NSDictionary *vec in self.connectionPaths) {
            NSArray *points = vec[@"points"];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:[points.firstObject CGPointValue]];
            [path addLineToPoint:[points.lastObject CGPointValue]];
            [path addLineToPoint:[points.firstObject CGPointValue]];
            [path closePath];
            [path setLineWidth:4];
            [[UIColor blackColor]setStroke];
            [[UIColor blackColor]setFill];
            [path stroke];
            [path fill];
            
            if (!self.connectionBezierPaths) {
                self.connectionBezierPaths = [NSMutableArray array];
                self.connectedPorts = [NSMutableArray array];
            }
            [self.connectionBezierPaths addObject:path];
            [self.connectedPorts addObject:vec[@"ports"]];
            
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
