//
//  BSDBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBox.h"
#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import <QuartzCore/QuartzCore.h>

@implementation BSDBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_panGesture];
        kAllowEdit = YES;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.21 alpha:1];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = self.backgroundColor.CGColor;
    }
    
    return self;
}

- (void)makeConnectionWithDescription:(BSDPortConnectionDescription *)description
{
    if (self.object == NULL || description== nil ) {
        return;
    }
    BSDBox *rb = (BSDBox *)description.receiverPortView.delegate;
    BSDInlet *inlet = (BSDInlet *)[[rb object]inletNamed:description.receiverPortName];
    BSDOutlet *myOutlet = (BSDOutlet *)[self.object outletNamed:description.senderPortName];
    BSDObjectOutputBlock block = ^(BSDObject *object,BSDOutlet *outlet){
        [rb senderValueChanged:outlet.value];
    };
    [myOutlet setOutputBlock:block];
    [myOutlet connectToInlet:inlet];
}

- (void)senderValueChanged:(id)value
{
    NSLog(@"object %@ %@ received value %@",self.className,self.uniqueId,value);
}

- (NSArray *)inlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *inlets = [self.object inlets];
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    frame.origin.y = 0;
    CGFloat step = 0;
    if (inlets.count > 1) {
        step = (bounds.size.width - frame.size.width)/(CGFloat)((inlets.count) - 1);
    }
    NSInteger idx = 0;
    NSMutableArray *result = [NSMutableArray array];
    for (BSDInlet *inlet in inlets) {
        frame.origin.x = (CGFloat)idx * step;
        BSDPortView *portView = [[BSDPortView alloc]initWithName:inlet.name delegate:self];
        portView.frame = frame;
        [result addObject:portView];
        [self addSubview:portView];
        idx ++;
    }
    
    return result;
}

- (NSArray *)outlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *outlets = [self.object outlets];
    NSLog(@"class %@ has %@ outlets",self.className,@(outlets.count));
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    frame.origin.y = bounds.size.height - frame.size.height;
    CGFloat step = 0;
    if (outlets.count > 1) {
        step = (bounds.size.width - frame.size.width)/(CGFloat)((outlets.count) - 1);
    }
    NSInteger idx = 0;
    NSMutableArray *result = [NSMutableArray array];
    for (BSDOutlet *outlet in outlets) {
        frame.origin.x = (CGFloat)idx * step;
        BSDPortView *portView = [[BSDPortView alloc]initWithName:outlet.name delegate:self];
        portView.frame = frame;
        [result addObject:portView];
        [self addSubview:portView];
        idx ++;
    }
    
    return result;
}

- (void)updatePortFrames
{

}

- (void)handlePan:(id)sender
{
    UIPanGestureRecognizer *recognizer = sender;
    CGPoint loc = [recognizer locationInView:self.superview];
    if (selectedPort == nil) {
        self.center = loc;
        [self.delegate boxDidMove:self];
    }else{
        
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
            {
                
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                [self.delegate box:self portView:selectedPort drawLineToPoint:loc];
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                [self.delegate box:self portView:selectedPort endedAtPoint:loc];
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (NSString *)parentClass
{
    return self.className;
}

- (NSString *)parentId
{
    return [self uniqueId];
}

- (NSString *)uniqueId
{
    return [NSString stringWithFormat:@"%p",self];
}

- (NSArray *)connections
{
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *portviews = [NSMutableArray array];
    [portviews addObjectsFromArray:self.inletViews];
    [portviews addObjectsFromArray:self.outletViews];
    for (BSDPortView *portView in portviews) {
        if (portView.connectedPortViews.count > 0) {
            
            for (BSDPortView *connectedPortView in portView.connectedPortViews) {
                BSDPortConnection *connection = [BSDPortConnection connectionWithOwner:portView target:connectedPortView];
                [temp addObject:connection];
            }
        }
    }
    
    return temp;
}

- (NSArray *)connectionVectors
{
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *portviews = [NSMutableArray array];
    [portviews addObjectsFromArray:self.inletViews];
    [portviews addObjectsFromArray:self.outletViews];
    for (BSDPortView *portView in portviews) {
        if (portView.connectedPortViews.count > 0) {
            
            for (BSDPortView *connectedPortView in portView.connectedPortViews) {
                BSDPortConnection *connection = [BSDPortConnection connectionWithOwner:portView target:connectedPortView];
                CGPoint o = [connection origin];
                CGPoint d = [connection destination];
                CGPoint ao = [self.superview convertPoint:o fromView:portView.superview];
                CGPoint ad = [self.superview convertPoint:d fromView:connectedPortView.superview];
                NSArray *points = @[[NSValue valueWithCGPoint:ao],[NSValue valueWithCGPoint:ad]];
                [temp addObject:points];
            }
        }
    }
    
    return temp;
}

- (void)tapInPortView:(id)sender
{
    BSDPortView *newPort = sender;
    
    if (newPort.isSelected) {
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = newPort;
        
    }else{
        
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = nil;
    }
}

- (void)makeObjectInstance
{
    [self makeObjectInstanceArgs:NULL];
}

- (void)makeObjectInstanceArgs:(id)args
{
    const char *class = [self.className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    
    if (args != NULL) {
        NSArray *a = args;
        if (a.count == 1) {
            id arg = a.firstObject;
            [invocation setArgument:&arg atIndex:2];
        }else{
            
            [invocation setArgument:&a atIndex:2];
        }
    }
    
    [invocation invoke];
    self.object = instance;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
