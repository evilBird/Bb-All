//
//  BbCocoaMessageView.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaMessageView.h"
#import "BbMessage.h"
#import "NSObject+Bb.h"

@implementation BbCocoaMessageView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    kMinWidth = 100.0;
    [self setupTextField];
    __weak BbCocoaMessageView *weakself = self;
    
    self.textEditingBeganHandler = ^(NSTextField *textField){
    };
    
    self.textEditingChangedHandler = ^(NSTextField *textField){
        [weakself invalidateIntrinsicContentSize];
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
    };
    
    self.textEditingEndedHandler = ^(NSString *text){
        [weakself.textField resignFirstResponder];
        NSString *string = weakself.textField.stringValue;
        NSLog(@"string: %@",string);
        [(BbMessage *)weakself.entity setMessageBuffer:text];
        [weakself invalidateIntrinsicContentSize];
    };
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return NSSizeFromCGSize(size);
}

- (NSColor *)defaultColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.85 alpha:1];
}

- (void)setSelected:(BOOL)selected
{
    if (selected != kSelected) {
        kSelected = selected;
        if (selected) {
            [self.textField setEditable:YES];
            [self.textField becomeFirstResponder];
            [self beginObservingText];
        }else{
            [[(BbMessage *)self.entity hotInlet]input:[BbBang bang]];
            [self.textField setEditable:NO];
            [self.textField resignFirstResponder];
            [self endObservingText];
        }
    }
}

+ (NSDictionary *)textAttributes
{
    NSFont *font = [NSFont fontWithName:@"Courier" size:[NSFont systemFontSize]];
    NSColor *color = [NSColor blackColor];
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
    if (self.textField.stringValue.length == 0) {
        self.textField.stringValue = [[(BbMessage *)self.entity messageBuffer]toString];
    }
    
    return self.textField.stringValue;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRect:self.bounds];
    [[NSColor blackColor]setStroke];
    [outlinePath setLineWidth:1];
    [outlinePath stroke];
}
@end
