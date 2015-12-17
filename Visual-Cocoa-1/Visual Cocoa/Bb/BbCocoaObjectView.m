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
#import "BbCocoaInletView.h"

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
    self.normalizedPosition = self.viewDescription.position;
    BbObject *myEntity = (BbObject *)entity;
    self.inletViews_ = [self addViewsForBbPortEntities:myEntity.inlets].mutableCopy;
    self.outletViews_ = [self addViewsForBbPortEntities:myEntity.outlets].mutableCopy;
}

- (void)setupConstraintsInParentView:(VCView *)parent
{
    [super setupConstraintsInParentView:parent];
    [self layoutInletViews:self.inletViews];
    [self layoutOutletViews:self.outletViews];
    
    if (self.textField) {
        [self setupTextFieldConstraints];
    }
}

- (VCSize)intrinsicContentSize
{
    CGSize size;
    size.width = [self contentWidthFromViewDescription:self.viewDescription];
    size.height = [self contentHeightFromViewDescription:self.viewDescription];
#if TARGET_OS_IPHONE
    return size;
#else
    return NSSizeFromCGSize(size);
#endif
}

- (CGFloat)contentWidthFromViewDescription:(BbCocoaEntityViewDescription *)viewDescription
{
    if (!viewDescription) {
        return kDefaultCocoaObjectViewWidth;
    }
    
    CGFloat contentWidth = kDefaultCocoaObjectViewWidth;
    
    if (viewDescription) {
        NSDictionary *textAttributes = [[self class] textAttributes];
        CGFloat textExpansion = [self textExpansionFactor];
        contentWidth = [self intrinsicWidthForObjectWithInlets:viewDescription.inlets
                                                       outlets:viewDescription.outlets
                                                 portViewWidth:kPortViewWidthConstraint
                                                 displayedText:viewDescription.text
                                       displayedTextAttributes:textAttributes
                                           textExpansionFactor:textExpansion
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
    return [VCView roundFloat:contentHeight];
}

- (CGFloat)editingTextExpansionFactor
{
    return 1.1;
}

- (CGFloat)defaultTextExpansionFactor
{
    return 1.05;
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
- (VCColor *)defaultColor
{
    return [VCColor blackColor];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.4 alpha:1];
}

+ (NSDictionary *)textAttributes
{
    
#if TARGET_OS_IPHONE
    VCFont *font = [VCFont fontWithName:@"Courier" size:[VCFont systemFontSize]];
#else
    VCFont *font = [VCFont fontWithName:@"Courier" size:[VCFont systemFontSize]];

#endif
    VCColor *color = [VCColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
#if TARGET_OS_IPHONE
    paragraphStyle.alignment = NSTextAlignmentCenter;
#else
    paragraphStyle.alignment = NSCenterTextAlignment;
#endif
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

- (void)setDisplayedText:(NSString *)displayedText
{
    self.viewDescription.text = displayedText;
    [self invalidateIntrinsicContentSize];
#if TARGET_OS_IPHONE
    [self setNeedsLayout];
    [self setNeedsDisplay];
#else
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
#endif

}

+ (instancetype)viewWithObject:(id)object parent:(id)parentView
{
    BbObject *obj = object;
    NSString *UIType = [[obj class]UIType];
    BbCocoaEntityViewDescription *desc = [BbCocoaEntityViewDescription viewDescriptionForObject:obj];
    return [BbCocoaObjectView viewWithBbUIType:UIType
                                        entity:obj
                                   description:desc
                                        parent:parentView];
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
    }else if ([type isEqualToString:kBbUITypeInlet]){
        return [[BbCocoaInletView alloc]initWithEntity:entity
                                       viewDescription:desc
                                              inParent:parentView];
    }else if ([type isEqualToString:kBbUITypeOutlet]){
        return [[BbCocoaOutletView alloc]initWithEntity:entity
                                        viewDescription:desc
                                               inParent:parentView];
    }
    
    return nil;
}

#pragma drawing

- (void)drawRect:(VCRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    // Drawing code here.
    if (!self.textField) {
        CGRect insetRect = CGRectInset(self.bounds,
                                       kPortViewWidthConstraint/2,
                                       kPortViewHeightConstraint + 2);
        
        NSString *textToDraw = self.displayedText;
        NSDictionary *textAttributes = [NSInvocation doClassMethod:NSStringFromClass([self class])
                                                      selectorName:@"textAttributes"
                                                              args:nil];
        [textToDraw drawInRect:insetRect withAttributes:textAttributes];
    }

}


@end
