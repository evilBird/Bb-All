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

@interface BSDCanvas ()

@property (nonatomic,strong)NSValue *connectionOriginPoint;
@property (nonatomic,strong)NSValue *connectionDestinationPoint;
@property (nonatomic,strong)NSMutableArray *connectionPaths;


@end

@implementation BSDCanvas

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _graphBoxes = [NSMutableArray array];
        _boxes = [NSMutableDictionary dictionary];
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _connectionPaths = [NSMutableArray array];
        [self addGestureRecognizer:_doubleTap];
        self.backgroundColor = [UIColor whiteColor];
        
        CGPoint pt = self.center;
        pt.y = 250;
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
        pt.y += 120;
        [self addNumberBoxAtPoint:pt];
        pt.x -= 200;
        [self addNumberBoxAtPoint:pt];
        pt.y += 120;
        [self addBangBoxAtPoint:pt];
        pt.x += 200;
        [self addBangBoxAtPoint:pt];
        pt.y += 120;
        [self addBangBoxAtPoint:pt];
        pt.x -= 200;
        [self addBangBoxAtPoint:pt];
        pt.y += 120;
        

        
        

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
        [self.boxes setValue:graphBox forKey:[graphBox uniqueId]];
        
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

}

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

- (void)addNumberBoxAtPoint:(CGPoint)point
{
    CGRect rect = CGRectMake(100, 100, 120, 44);
    BSDNumberBox *numberBox = [[BSDNumberBox alloc]initWithFrame:rect];
    numberBox.delegate = self;
    numberBox.center = point;
    [self addSubview:numberBox];
    [self.graphBoxes addObject:numberBox];
    [self.boxes setValue:numberBox forKey:[numberBox uniqueId]];
    [self box:numberBox instantiateObjectWithName:numberBox.className];
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
