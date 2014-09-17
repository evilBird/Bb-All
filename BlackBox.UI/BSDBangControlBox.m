//
//  BSDBangBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBangControlBox.h"
#import "BSDPatch.h"

@interface BSDBangControlBox ()

@property (nonatomic,strong)UIColor *defaultColor;
@property (nonatomic,strong)UIColor *highightColor;
@property (nonatomic,strong)UIColor *currentColor;

@end

@implementation BSDBangControlBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDBangBox";
        [self makeObjectInstance];
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        self.defaultColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.highightColor = [UIColor colorWithWhite:0.5 alpha:1];
        self.currentColor = self.defaultColor;
    }
    return self;
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
    NSMutableArray *result = [NSMutableArray array];
    BSDInlet *inlet = inlets.firstObject;
    frame.origin.x = 0;
    BSDPortView *portView = [[BSDPortView alloc]initWithName:inlet.name delegate:self];
    portView.frame = frame;
    [result addObject:portView];
    [self addSubview:portView];
    
    return result;
}

/*
- (instancetype)initWithDescription:(BSDObjectDescription *)desc
{
    self = [super initWithDescription:desc];
    if (self) {
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        self.defaultColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.highightColor = [UIColor colorWithWhite:0.5 alpha:1];
        self.currentColor = self.defaultColor;
    }
    return self;
}
*/
- (void)senderValueChanged:(id)value
{
    [self doHighlight];
    [self performSelector:@selector(endHighlight) withObject:nil afterDelay:0.05];
}

- (void)doHighlight
{
    self.currentColor = self.highightColor;
    [self setNeedsDisplay];
    [self.object calculateOutput];
    //[[self.object outletNamed:@"main"]setValue:[BSDBang bang]];
}

- (void)endHighlight
{
    self.currentColor = self.defaultColor;
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        
        [self doHighlight];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        [self endHighlight];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [self hitTest:[touches.allObjects.lastObject locationInView:self] withEvent:event];
    if (![view isKindOfClass:[BSDPortView class]]) {
        
        [self endHighlight];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect offsetRect = CGRectOffset(self.bounds, 4, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(offsetRect, 6, 6)];
    [self.currentColor setFill];
    [path fill];
}

@end
