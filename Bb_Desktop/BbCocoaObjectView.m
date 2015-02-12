//
//  BbCocoaObjectView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaObjectView.h"
#import "BbCocoaPortView.h"
#import "BbCocoaObjectView+Autolayout.h"

@interface BbViewDescription ()
{
    
}

@end

@implementation BbViewDescription

+ (NSDictionary *)textAttributes
{
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:[BbViewDescription paragraphStyle]
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

@interface BbCocoaObjectView ()

- (CGFloat)contentWidthFromViewDescription:(BbViewDescription *)configuration;
- (CGFloat)contentHeightFromViewDescription:(BbViewDescription *)configuration;

@property (nonatomic,strong)NSMutableArray *inletViews_;
@property (nonatomic,strong)NSMutableArray *outletViews_;
@property (nonatomic,strong)NSMutableArray *inletSpacers;
@property (nonatomic,strong)NSMutableArray *outletSpacers;

@end

@implementation BbCocoaObjectView

#pragma mark - Public Methods



- (void)commonInit
{
    [super commonInit];
    if (!self.viewDescription) {
        return;
    }
    
    if (self.viewDescription.inlets > 0) {
        self.inletViews_ = [self addPortViewsCount:self.viewDescription.inlets].mutableCopy;
    }
    
    if (self.viewDescription.outlets > 0) {
        self.outletViews_ = [self addPortViewsCount:self.viewDescription.outlets].mutableCopy;
    }
}


- (void)commonInitDescription:(id)viewDescription
{
    [super commonInitDescription:viewDescription];
    if (!viewDescription) {
        return;
    }
    self.viewDescription = viewDescription;
    self.inletViews_ = [self addPortViewsCount:self.viewDescription.inlets].mutableCopy;
    self.outletViews_ = [self addPortViewsCount:self.viewDescription.outlets].mutableCopy;
}

- (void)setupConstraintsParent:(NSView *)parent
{
    [super setupConstraintsParent:parent];
}

- (void)setupConstraints
{
    [super setupConstraints];
    if (!self.superview) {
        return;
    }
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.width = [self contentWidthFromViewDescription:self.viewDescription];
    size.height = [self contentHeightFromViewDescription:self.viewDescription];
    return NSSizeFromCGSize(size);
}

- (CGFloat)contentWidthFromViewDescription:(BbViewDescription *)viewDescription
{
    if (!viewDescription) {
        return kDefaultCocoaObjectViewWidth;
    }
    
    CGFloat contentWidth = [BbCocoaObjectView widthForInlets:viewDescription.inlets
                                                     outlets:viewDescription.outlets
                                                        text:viewDescription.text];
    if (contentWidth > kDefaultCocoaObjectViewWidth) {
        return contentWidth;
    }else{
        return kDefaultCocoaObjectViewWidth;
    }
}

- (CGFloat)contentHeightFromViewDescription:(BbViewDescription *)viewDescription
{
    if (!viewDescription) {
        return kDefaultCocoaObjectViewHeight;
    }
    
    return kDefaultCocoaObjectViewHeight;
}

#pragma accessors

- (NSArray *)inletViews
{
    return self.inletViews_.mutableCopy;
}

- (NSArray *)outletViews
{
    return self.outletViews_.mutableCopy;
}

#pragma mark - Overrides
- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1];
}


#pragma constructors

+ (instancetype)viewWithDescription:(BbViewDescription *)viewDescription
                           inParent:(BbCocoaEntityView *)parentView
{
    BbCocoaObjectView *objectView = [[BbCocoaObjectView alloc]initWithDescription:viewDescription
                                                                         inParent:parentView];
    return objectView;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    CGRect insetRect = CGRectInset(self.bounds,
                                   kPortViewWidthConstraint/2,
                                   kPortViewHeightConstraint + 2);
    
    NSString *textToDraw = self.viewDescription.text;
    [textToDraw drawInRect:insetRect withAttributes:[BbViewDescription textAttributes]];
}


@end
