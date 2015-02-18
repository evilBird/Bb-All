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
    __weak BbCocoaPlaceholderObjectView *weakself = self;
    self.textEditingEndedHandler = ^(NSString *text){
        if (text && text.length > 1) {
            [weakself.delegate placeholder:weakself enteredText:text];
        }
    };
}

- (void)setupConstraintsInParentView:(id)parent
{
    [super setupConstraintsInParentView:parent];
    [self setupTextFieldConstraints];
}

- (NSColor *)defaultColor
{
    return [NSColor blackColor];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.3 alpha:1.0];
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

@end
