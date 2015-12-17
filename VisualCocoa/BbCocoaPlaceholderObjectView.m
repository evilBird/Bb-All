//
//  BbCocoaPlaceholderObjectView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/11/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaPlaceholderObjectView.h"
#import "BbCocoaPortView.h"
#import "BbCocoaObjectView.h"
#import "BbUI.h"

@implementation BbCocoaPlaceholderObjectView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    [self setupTextField];
    kMinWidth = 100.0;
    
    __weak BbCocoaPlaceholderObjectView *weakself = self;
    
    
    self.textEditingChangedHandler = ^(VCTextField *text){
        [weakself invalidateIntrinsicContentSize];
#if TARGET_OS_IPHONE == 1
        [weakself setNeedsDisplay];
        [weakself.superview setNeedsDisplay];
        
#else
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
#endif

    };
    
    self.textEditingEndedHandler = ^(NSString *text){
        if (text && text.length > 1) {
            [weakself.delegate placeholder:weakself enteredText:text];
        }
    };
    
    self.editing = YES;
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self setupTextFieldConstraints];
}

- (CGFloat)intrinsicTextWidth
{
#if TARGET_OS_IPHONE
    NSString *text = [NSString stringWithString:self.textField.text];
#else
    NSString *text = [NSString stringWithString:self.textField.stringValue];
#endif
    NSDictionary *textAttributes = [[self class]textAttributes];
    CGFloat textWidthRaw = [text sizeWithAttributes:textAttributes].width;
    CGFloat textWidth = pow(textWidthRaw, 1.1);
    return textWidth;
}

- (VCColor *)defaultColor
{
    return [VCColor blackColor];
}

- (VCColor *)selectedColor
{
    return [VCColor colorWithWhite:0.4 alpha:1.0];
}

+ (NSDictionary *)textAttributes
{
    VCFont *font = [VCFont fontWithName:@"Courier" size:[VCFont systemFontSize]];
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

- (instancetype)initWithDelegate:(id<BbPlaceholderViewDelegate>)delegate
                 viewDescription:(id)viewDescription
                        inParent:(id)parentView
{
    self = [super initWithEntity:nil
                 viewDescription:viewDescription
                        inParent:parentView];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selected"];
    [self removeObserver:self forKeyPath:@"editing"];
}

@end
