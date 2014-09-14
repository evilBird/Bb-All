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
        _inletViews = [NSMutableArray arrayWithArray:[self inlets]];
        _outletViews = [NSMutableArray arrayWithArray:[self outlets]];
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

- (NSArray *)inlets
{
    return nil;
}
- (NSArray *)outlets
{
    return nil;
}

- (void)updatePortFrames
{

    /*
    
    NSMutableArray *toUpdate = [NSMutableArray arrayWithArray:self.inletViews];
    [toUpdate addObjectsFromArray:self.outletViews];
    
    for (BSDPortView *inletView in self.inletViews) {
        CGRect bounds = self.bounds;
        CGRect frame;
        frame.size.width = bounds.size.width * 0.35;
        frame.size.height = bounds.size.height * 0.25;
        if ([inletView.portName isEqualToString:@"hotInlet"]) {
            frame.origin = bounds.origin;
            inletView.frame = frame;
        }else if ([inletView.portName isEqualToString:@"coldInlet"]){
            frame.origin.x = bounds.size.width - frame.size.width;
            frame.origin.y = 0;
            inletView.frame = frame;
        }
    }
    
    for (BSDPortView *outletView in self.outletViews) {
        
        CGRect bounds = self.bounds;
        CGRect frame;
        frame.size.width = bounds.size.width * 0.35;
        frame.size.height = bounds.size.height * 0.25;
        frame.origin.x = 0;
        frame.origin.y = bounds.size.height - frame.size.height;
        outletView.frame = frame;
    }
     */
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
