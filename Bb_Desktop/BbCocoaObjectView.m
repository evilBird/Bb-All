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
#import "BbObject.h"
#import "BbCocoaMessageView.h"
#import "BbCocoaHSliderView.h"
#import "NSInvocation+Bb.h"
#import "BbCocoaBangView.h"

@interface BbCocoaObjectView ()

- (CGFloat)contentWidthFromViewDescription:(BbCocoaEntityViewDescription *)configuration;
- (CGFloat)contentHeightFromViewDescription:(BbCocoaEntityViewDescription *)configuration;

@property (nonatomic,strong)NSMutableArray *inletViews_;
@property (nonatomic,strong)NSMutableArray *outletViews_;

@end

@implementation BbCocoaObjectView

#pragma mark - Public Methods


- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    self.viewDescription = viewDescription;
    self.normalizedPosition = self.viewDescription.normalizedPosition;
    BbObject *myEntity = (BbObject *)entity;
    self.inletViews_ = [self addViewsForBbPortEntities:myEntity.inlets].mutableCopy;
    self.outletViews_ = [self addViewsForBbPortEntities:myEntity.outlets].mutableCopy;
}

- (void)setupConstraintsInParentView:(NSView *)parent
{
    [super setupConstraintsInParentView:parent];
    [self layoutInletViews:self.inletViews];
    [self layoutOutletViews:self.outletViews];
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.width = [self contentWidthFromViewDescription:self.viewDescription];
    size.height = [self contentHeightFromViewDescription:self.viewDescription];
    return NSSizeFromCGSize(size);
}

- (CGFloat)contentWidthFromViewDescription:(BbCocoaEntityViewDescription *)viewDescription
{
    if (!viewDescription) {
        return kDefaultCocoaObjectViewWidth;
    }
    
    CGFloat contentWidth = kDefaultCocoaObjectViewWidth;
    
    if (viewDescription) {
        NSDictionary *textAttributes = [[self class] textAttributes];
        contentWidth = [self intrinsicWidthForObjectWithInlets:viewDescription.inlets
                                                       outlets:viewDescription.outlets
                                                 portViewWidth:kPortViewWidthConstraint
                                                 displayedText:viewDescription.text
                                       displayedTextAttributes:textAttributes
                                                minPortSpacing:kMinHorizontalSpacerSize
                                                  defaultWidth:kDefaultCocoaObjectViewWidth];
    }
    
    static CGFloat prevContentWidth;
    if (contentWidth != prevContentWidth) {
        [self invalidateIntrinsicContentSize];
        prevContentWidth = contentWidth;
    }
    
    return contentWidth;
}

- (CGFloat)contentHeightFromViewDescription:(BbCocoaEntityViewDescription *)viewDescription
{
    CGFloat contentHeight = kPortViewHeightConstraint * 2.0 + kMinVerticalSpacerSize;
    return [NSView roundFloat:contentHeight];
}

- (void)setCenter:(CGPoint)center
{
    
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

+ (NSDictionary *)textAttributes
{
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.alignment = NSCenterTextAlignment;
    NSDictionary *textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:color,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
    return textAttributes;
}

- (NSString *)displayedText
{
    return self.viewDescription.text;
}

+ (instancetype)viewWithBbUIType:(id)type
                          entity:(id)entity
                     description:(id)desc
                          parent:(id)parentView
{
    if ([type isEqualToString:kBbUITypeObject]) {
        return [[BbCocoaObjectView alloc]initWithEntity:entity
                                        viewDescription:desc inParent:parentView];
    }else if ([type isEqualToString:kBbUITypeHorizontalSlider]){
        return [[BbCocoaHSliderView alloc]initWithEntity:entity
                                         viewDescription:desc inParent:parentView];
    }else if ([type isEqualToString:kBbUITypeMessage]){
        return [[BbCocoaMessageView alloc]initWithEntity:entity
                                         viewDescription:desc inParent:parentView];
    }else if ([type isEqualToString:kBbUITypeBang]){
        return [[BbCocoaBangView alloc]initWithEntity:entity
                                      viewDescription:desc inParent:parentView];
    }
    
    return nil;
}

#pragma drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    CGRect insetRect = CGRectInset(self.bounds,
                                   kPortViewWidthConstraint/2,
                                   kPortViewHeightConstraint + 2);
    
    NSString *textToDraw = self.displayedText;
    NSDictionary *textAttributes = [NSInvocation doClassMethod:NSStringFromClass([self class])
                                                  selectorName:@"textAttributes"
                                                          args:nil];
    [textToDraw drawInRect:insetRect withAttributes:textAttributes];
}


@end
