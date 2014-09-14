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

@interface BSDCanvas ()

@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;
@property (nonatomic,strong)UIButton *compileButton;
@property (nonatomic,strong)BSDCompiledPatch *compiledPatch;


@end

@implementation BSDCanvas

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _graphBoxes = [NSMutableArray array];
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _connectionPaths = [NSMutableArray array];
        [self addGestureRecognizer:_doubleTap];
        self.backgroundColor = [UIColor whiteColor];
        _compileButton = [UIButton new];
        [_compileButton setTitle:@"Compile" forState:UIControlStateNormal];
        [_compileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_compileButton addTarget:self action:@selector(tapInCompileButton:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = self.bounds;
        frame.size.width *= 0.1;
        frame.size.height *= 0.05;
        frame.origin.x = self.bounds.size.width - frame.size.width - 20;
        frame.origin.y = 20;
        _compileButton.frame = frame;
        _compileButton.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
        _compiledPatch = [[BSDCompiledPatch alloc]initWithArguments:nil];
        CGPoint pt = self.center;
        pt.x -= 100;
        [self addNumberBoxAtPoint:pt];
        pt.x += 200;
        [self addNumberBoxAtPoint:pt];
        pt.y += 120;
        [self addNumberBoxAtPoint:pt];
        pt.x -= 200;
        [self addNumberBoxAtPoint:pt];
        pt.y += 120;
        [self addNumberBoxAtPoint:pt];
        pt.x += 200;
        [self addNumberBoxAtPoint:pt];
        

        //[self addSubview:_compileButton];
    }
    
    return self;
}


- (void)handleDoubleTap:(id)sender
{
    CGPoint loc = [sender locationOfTouch:0 inView:self];
    UIView *theView = [self hitTest:loc withEvent:UITouchPhaseBegan];
    if (![theView isKindOfClass:[BSDGraphBox class]] && ![theView isKindOfClass:[BSDPortView class]] && ![theView isKindOfClass:[UITextField class]]) {
        
        CGRect rect = CGRectMake(0, 0, 140, 50);
        BSDGraphBox *graphBox = [[BSDGraphBox alloc]initWithFrame:rect];
        graphBox.delegate = self;
        graphBox.center = loc;
        [self addSubview:graphBox];
        [self.graphBoxes addObject:graphBox];
    }else if ([theView isKindOfClass:[BSDGraphBox class]]){
        [self.graphBoxes removeObject:theView];
        [theView removeFromSuperview];
    }else if ([theView isKindOfClass:[UITextField class]]){
        
        [self.graphBoxes removeObject:theView.superview];
        [theView.superview removeFromSuperview];
    }
    
}

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

- (void)box:(id)sender instantiateObjectWithName:(NSString *)name
{
    BSDBox *gb = sender;
    if (name) {
        BSDObjectDescription *desc = [[BSDObjectDescription alloc]init];
        desc.className = gb.className;
        desc.uniqueId = gb.uniqueId;
        [self.compiledPatch addObjectWithDescription:desc];
    }
}

- (void)connectPortView:(BSDPortView *)sender toPortView:(BSDPortView *)receiver
{
    BSDPortConnectionDescription *cd = [[BSDPortConnectionDescription alloc]init];
    cd.senderParentId = [sender.delegate parentId];
    cd.senderPortName = [sender portName];
    cd.receiverParentId = [receiver.delegate parentId];
    cd.receiverPortName = [receiver portName];
    [self.compiledPatch addConnectionWithDescription:cd];
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

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 120, 44);
    BSDNumberBox *numberBox = [[BSDNumberBox alloc]initWithFrame:rect];
    numberBox.delegate = self;
    numberBox.center = point;
    [self addSubview:numberBox];
    [self.graphBoxes addObject:numberBox];
    [self box:numberBox instantiateObjectWithName:numberBox.className];
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

@end
