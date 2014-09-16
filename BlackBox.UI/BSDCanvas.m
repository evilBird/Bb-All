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
#import <ObjC/runtime.h>

@interface BSDCanvas ()

@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;
@property (nonatomic,strong)NSMutableArray *highlightedPaths;


@property (nonatomic,strong)UIView *testView;
@property (nonatomic,strong)NSArray *allowedObjects;


@end

@implementation BSDCanvas

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.allowedObjects = [self classList];
        
        _graphBoxes = [NSMutableArray array];
        _boxes = [NSMutableDictionary dictionary];
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:_doubleTap];
        _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        _longPress.allowableMovement = 10;
        [self addGestureRecognizer:_longPress];
        _connectionPaths = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
        //[self addUtilityObjects];
        //[self testBangBox];
        //[self testNumberBox];
    }
    
    return self;
}

- (void)addUtilityObjects
{
    CGFloat y = 50;
    CGFloat step = 70;
    for (NSInteger i = 0; i < 8; i++) {
        CGPoint pt;
        pt.x = self.bounds.size.width - 150;
        pt.y = i * step + y;
        [self addNumberBoxAtPoint:pt];
    }
    
    for (NSInteger i = 8; i < 14; i++) {
        CGPoint pt;
        pt.x = self.bounds.size.width - 150;
        pt.y = i * step + y;
        [self addBangBoxAtPoint:pt];
    }
}

- (void)handleDoubleTap:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    UIView *theView = [self hitTest:loc withEvent:UITouchPhaseBegan];
    
    if ([theView isKindOfClass:[BSDBox class]] || [theView.superview isKindOfClass:[BSDBox class]]) {
        return;
    }
    
    CGRect rect = CGRectMake(0, 0, 140, 50);
    BSDGraphBox *graphBox = [[BSDGraphBox alloc]initWithFrame:rect];
    graphBox.delegate = self;
    graphBox.center = loc;
    [self addSubview:graphBox];
    [self.graphBoxes addObject:graphBox];
    [self.boxes setValue:graphBox forKey:[graphBox uniqueId]];
    
    
}

- (void)handleLongPress:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    UIView *theView = [self hitTest:loc withEvent:UITouchPhaseBegan];
    if (![theView isKindOfClass:[BSDBox class]] && ![theView.superview isKindOfClass:[BSDBox class]]) {
        return;
    }
    
    
    /*
    BSDBox *box = nil;
    if ([theView isKindOfClass:[BSDBox class]]) {
        box = (BSDBox *)theView;
        NSLog(@"tap in %@ box",box.className);
        return;
    }
     */
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
}

- (void)box:(id)sender portView:(id)portView endedAtPoint:(CGPoint)point
{
    BSDPortView *pv = portView;
    UIView *theView = [self hitTest:point withEvent:nil];
    
    if ([theView isKindOfClass:[BSDPortView class]]) {
        BSDPortView *newConnection = (BSDPortView *)theView;
        [pv addConnectionToPortView:newConnection];
        [self connectPortView:pv toPortView:newConnection];
    }
    
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.connectionPaths = nil;
    self.connectionPaths = [NSMutableArray arrayWithArray:[self allConnections]];
    [self setNeedsDisplay];
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
    NSMutableArray *lowercase = [NSMutableArray array];
    for (NSString *className in self.allowedObjects) {
        [lowercase addObject:[className lowercaseString]];
    }
    
    if ([lowercase containsObject:[text lowercaseString]]){
        NSInteger idx = [lowercase indexOfObject:[text lowercaseString]];
        return self.allowedObjects[idx];
    }
    
    return nil;
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
    for (BSDBox *gb in self.graphBoxes) {
        NSArray *connections = [self connectionsInBox:gb];
        if (connections) {
            [temp addObjectsFromArray:connections];
        }
    }
    return temp;
}

- (NSArray *)connectionsInBox:(BSDBox *)box
{
    return [box connectionVectors];
}

- (id)canvas
{
    return self;
}

- (NSDictionary *)currentPatch
{
    NSMutableArray *objectDescriptions = [NSMutableArray array];
    NSMutableArray *connectionDescriptions = [NSMutableArray array];
    //enumerate all boxes, get object descriptions for each
    for (BSDBox *box in self.boxes.allValues) {
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

- (NSArray *)classList;
{
    unsigned outCount;
    Class *classes = objc_copyClassList(&outCount);
    NSMutableSet *result = nil;
    for (unsigned i = 0; i < outCount; i++) {
        Class theClass = classes[i];
        Class superClass = class_getSuperclass(theClass);
        NSString *className = NSStringFromClass(theClass);
        NSString *superClassName = NSStringFromClass(superClass);
        if ([superClassName isEqualToString:@"BSDObject"]) {
            
            if (!result) {
                result = [NSMutableSet set];
            }
            [result addObject:className];
        }
    }
    
    free(classes);
    return result.allObjects;
}

- (void)loadPatchWithDictionary:(NSDictionary *)dictionary
{
    NSArray *objs = dictionary[@"objectDescriptions"];
    NSArray *connects = dictionary[@"connectionDescriptions"];

    for (NSDictionary *dict in objs) {
        BSDObjectDescription *desc = [BSDObjectDescription objectDescriptionWithDictionary:dict];
        [self makeBoxWithDescription:desc];
    }
    
    for (NSDictionary *dict in connects) {
        BSDPortConnectionDescription *desc = [BSDPortConnectionDescription connectionDescriptionWithDictionary:dict];
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

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 120, 44);
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

- (void)clearCurrentPatch
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.boxes = nil;
    self.graphBoxes = nil;
    self.connectionPaths = nil;
    self.connectionOriginPoint = nil;
    self.connectionDestinationPoint = nil;
    self.boxes = [NSMutableDictionary dictionary];
    self.graphBoxes = [NSMutableArray array];
    self.connectionPaths = [NSMutableArray array];
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    if (self.connectionOriginPoint && self.connectionDestinationPoint) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[self.connectionOriginPoint CGPointValue]];
        [path addLineToPoint:[self.connectionDestinationPoint CGPointValue]];
        [path setLineWidth:2];
        [[UIColor blackColor]setStroke];
        [path stroke];
    }
    
    if (self.connectionPaths != nil) {
        for (NSArray *points in self.connectionPaths) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:[points.firstObject CGPointValue]];
            [path addLineToPoint:[points.lastObject CGPointValue]];
            [path setLineWidth:1.5];
            [[UIColor blackColor]setStroke];
            [path stroke];
        }
    }
}

- (void)testNumberBox
{
    [self addNumberBoxAtPoint:self.center];
    
}

- (void)testBangBox
{
    [self addBangBoxAtPoint:self.center];
}


@end
