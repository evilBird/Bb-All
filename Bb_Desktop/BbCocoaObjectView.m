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

@interface BbObjectViewConfiguration ()
{
    BOOL kIsPlaceholder;
}

@end



@implementation BbObjectViewConfiguration


- (void)setEntityViewType:(NSString *)entityViewType
{
    _entityViewType = entityViewType;
    if ([entityViewType isEqualToString:@"placeholder"]) {
        kIsPlaceholder = YES;
    }else{
        kIsPlaceholder = NO;
    }
}

+ (NSDictionary *)textAttributes
{
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:[BbObjectViewConfiguration paragraphStyle]
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
    
    if (!self.configuration) {
        return;
    }
    self.inletViews_ = [self portViewsWithCount:self.configuration.inlets].mutableCopy;
    self.outletViews_ = [self portViewsWithCount:self.configuration.outlets].mutableCopy;
    self.inletSpacers = [self spacerViewsForPortViews:self.inletViews_].mutableCopy;
    self.outletSpacers = [self spacerViewsForPortViews:self.outletViews_].mutableCopy;
}

- (void)setupConstraints
{
    [super setupConstraints];
    [self setWidth:[BbCocoaObjectView widthForInlets:self.configuration.inlets
                                             outlets:self.configuration.outlets
                                                text:self.configuration.text]
            height:kPortViewHeightConstraint * 2 + kMinVerticalSpacerSize];
    if (self.configuration) {
        [self layoutPortviews:self.inletViews spacers:self.inletSpacers isTopRow:YES];
        [self layoutPortviews:self.outletViews spacers:self.outletSpacers isTopRow:NO];
    }
    
    [self refreshEntityView];
    [self setCenter:self.configuration.center];
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

+ (instancetype)viewWithConfiguration:(BbObjectViewConfiguration *)config
                           parentView:(BbCocoaEntityView *)parentView
{
    CGRect frame = [NSView rect:CGRectMake(0, 0, 100, 50) withCenter:config.center];
    BbCocoaObjectView *objectView = [[BbCocoaObjectView alloc]initWithFrame:frame                                                            parentView:parentView
                                                                     config:config];
    return objectView;
}

- (instancetype)initWithFrame:(NSRect)frameRect
                   parentView:(BbCocoaEntityView *)parentView
                       config:(BbObjectViewConfiguration *)config
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _configuration = config;
        [self commonInit];
        self.parentView = parentView;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
                   parentView:(BbCocoaEntityView *)parentView
                       config:(BbObjectViewConfiguration *)config

{
    self = [super initWithCoder:coder];;
    if (self) {
        _configuration = config;
        [self commonInit];
        self.parentView = parentView;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithCoder:coder
                    parentView:nil
                        config:nil];
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    return [self initWithFrame:frameRect
                    parentView:nil
                        config:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    CGRect insetRect = CGRectInset(self.bounds,
                                   kPortViewWidthConstraint/2,
                                   kPortViewHeightConstraint + 2);
    
    NSString *textToDraw = self.configuration.text;
    [textToDraw drawInRect:insetRect withAttributes:[BbObjectViewConfiguration textAttributes]];
}


@end
