//
//  TestView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/9/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbBoxView.h"

@implementation BbDisplayConfiguration

+ (NSDictionary *)textAttributes
{
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:[BbDisplayConfiguration paragraphStyle]
                                     };
    return textAttributes;
}

+ (NSParagraphStyle *)paragraphStyle
{
    NSMutableParagraphStyle *result = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    result.alignment = NSCenterTextAlignment;
    return result;
}

@end













@interface BbPortView ()

{
    NSColor *kDefaultBackgroundColor;
    NSColor *kSelectedBackgroundColor;
}

@property (nonatomic,strong) NSArray *portViews;

@end

@implementation BbPortView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        kDefaultBackgroundColor = [NSColor whiteColor];
        kSelectedBackgroundColor = [NSColor colorWithWhite:0.7 alpha:1];
        _selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    if (selected != _selected) {
        _selected = selected;
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    // Drawing code here.
    NSColor *backgroundColor;
    CGRect rectToDraw = self.bounds;
    if (!self.selected) {
        backgroundColor = kDefaultBackgroundColor;
        self.layer.affineTransform = CGAffineTransformIdentity;
        self.layer.backgroundColor = backgroundColor.CGColor;
        NSLog(@"deselected");
    }else{
        backgroundColor = kSelectedBackgroundColor;
        //rectToDraw = CGRectInset(self.bounds, -4, -4);
        self.layer.affineTransform = CGAffineTransformMakeScale(2, 2);
        self.layer.backgroundColor = backgroundColor.CGColor;

        NSLog(@"selected");
    }
    //self.bounds = rectToDraw;
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:rectToDraw];
    [backgroundPath setLineWidth:1];
    [backgroundColor setFill];
    [[NSColor blackColor]setStroke];
    [backgroundPath fill];
    [backgroundPath stroke];
    //[self.superview setNeedsDisplayInRect:rectToDraw];
}

@end













@interface BbBoxView ()
{
    NSColor *kDefaultBackgroundColor;
    NSColor *kSelectedBackgroundColor;
}

@property (nonatomic,strong)NSArray *portViews;

@end

@implementation BbBoxView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        kDefaultBackgroundColor = [NSColor blackColor];
        kSelectedBackgroundColor = [NSColor colorWithWhite:0.3 alpha:1.0];
        _selected = NO;
    }
    return self;
}

- (void)setDisplayConfiguration:(BbDisplayConfiguration *)displayConfiguration
{
    _displayConfiguration = displayConfiguration;
    [self setNeedsDisplay:YES];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    // Drawing code here.
    
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:self.bounds];
    [backgroundPath setLineWidth:1];
    
    NSColor *backgroundColor;
    if (!self.selected) {
        backgroundColor = kDefaultBackgroundColor;
    }else{
        backgroundColor = kSelectedBackgroundColor;
    }
    
    NSColor *white = [NSColor whiteColor];
    [white setStroke];
    [backgroundColor setFill];
    [backgroundPath fill];
    [backgroundPath stroke];
    
    NSUInteger num_ports = self.displayConfiguration.inlets + self.displayConfiguration.outlets;
    
    CGRect insetRect = CGRectInset(self.bounds,
                                   self.displayConfiguration.portSize.width/2,
                                   self.displayConfiguration.portSize.height + 2);
    
    NSString *textToDraw = self.displayConfiguration.text;
    [textToDraw drawInRect:insetRect withAttributes:[BbDisplayConfiguration textAttributes]];
    
    if (num_ports == 0) {
        return;
    };

    if (self.portViews && self.portViews.count == num_ports) {
        return;
    }
    
    self.portViews = nil;
    NSMutableArray *portViews = [NSMutableArray array];
    NSRect portRect;
    portRect.origin.x = 1;
    portRect.origin.y = CGRectGetMaxY(self.bounds) - self.displayConfiguration.portSize.height - 1;
    portRect.size = self.displayConfiguration.portSize;
    NSUInteger numberOfElements = (self.displayConfiguration.inlets * 2) - 1;
    
    for (NSUInteger i = 0; i<numberOfElements; i++)
    {
        BOOL drawSpacer = (i%2 == 1);
        if (drawSpacer) {
            portRect.origin.x+=self.displayConfiguration.spacerSize.width;
        }else{
            
            BbPortView *portView = [[BbPortView alloc]initWithFrame:portRect];
            if (portView) {
                [portViews addObject:portView];
            }
            
            [self addSubview:portView];
            [portView setNeedsDisplay:YES];
            portRect.origin.x+=self.displayConfiguration.portSize.width;
        }
    }
    portRect.origin.x = 1;
    portRect.origin.y = 1;
    numberOfElements = (self.displayConfiguration.outlets * 2) - 1;

    for (NSUInteger i = 0; i<numberOfElements; i++)
    {
        BOOL drawSpacer = (i%2 == 1);
        if (drawSpacer) {
            portRect.origin.x+=self.displayConfiguration.spacerSize.width;
        }else{
            BbPortView *portView = [[BbPortView alloc]initWithFrame:portRect];
            if (portView) {
                [portViews addObject:portView];
            }
            [self addSubview:portView];
            [portView setNeedsDisplay:YES];
            portRect.origin.x+=self.displayConfiguration.spacerSize.width;
        }
    }
    
    self.portViews = [NSArray arrayWithArray:portViews];

}


@end
