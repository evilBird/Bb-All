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
#import "NSString+Bb.h"
#import "NSMutableString+Bb.h"

@implementation BbCocoaMessageView

- (void)commonInitEntity:(BbEntity *)entity viewDescription:(id)viewDescription
{
    [super commonInitEntity:entity viewDescription:viewDescription];
    kMinWidth = 100.0;
    [self setupTextField];
    
    __weak BbCocoaMessageView *weakself = self;
    self.textEditingChangedHandler = ^(NSTextField *textField){
        [weakself invalidateIntrinsicContentSize];
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
    };
    
    self.textEditingEndedHandler = ^(NSString *text){
        
        NSMutableString *mutable = [NSMutableString stringWithString:text];
        [mutable trimWhiteSpace];
        NSString *message = [NSString stringWithString:mutable.mutableCopy];
        [(BbMessage *)weakself.entity setMessageWithText:text];
        weakself.textField.stringValue = message;
        [weakself invalidateIntrinsicContentSize];
        [weakself setNeedsDisplay:YES];
        [weakself.superview setNeedsDisplay:YES];
    };
    
    self.editing = NO;
}

- (NSSize)intrinsicContentSize
{
    CGSize size;
    size.height = [self intrinsicContentHeight];
    size.width = [self intrinsicContentWidth];
    return NSSizeFromCGSize(size);
}

- (CGFloat)editingTextExpansionFactor
{
    return 1.1;
}

- (CGFloat)defaultTextExpansionFactor
{
    return 1.07;
}

- (NSColor *)defaultColor
{
    return [NSColor colorWithWhite:0.9 alpha:1];
}

- (NSColor *)selectedColor
{
    return [NSColor colorWithWhite:0.8 alpha:1];
}

- (NSColor *)sendingColor
{
    return [NSColor colorWithWhite:0.7 alpha:1];
}

- (NSColor *)editingColor
{
    return [NSColor whiteColor];
}

- (void)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
    if (commandSelector == @selector(insertNewline:)) {
        //Do something against ENTER key
        if (self.editing) {
            [self endEditingText];
            self.editing = NO;
            NSString *text = [NSString stringWithString:self.textField.stringValue];
            self.textEditingEndedHandler(text);
        }
    }
}

- (void)sendMessage
{
    [[(BbMessage *)self.entity hotInlet]input:[BbBang bang]];
    self.sending = YES;
    [self setNeedsDisplay:YES];
    __weak BbCocoaMessageView *weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself endMessage];
    });
}

- (void)endMessage
{
    self.sending = NO;
    [self setNeedsDisplay:YES];
}

- (id)clickDown:(NSEvent *)theEvent
{
    [super clickDown:theEvent];
    [self sendMessage];
    if (self.selected) {
        return self;
    }
    
    return nil;
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

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    // Drawing code here.
    
    NSColor *fillColor;
    if (self.sending) {
        fillColor = [self sendingColor];
    }else if (self.editing){
        fillColor = self.editingColor;
    }else if (self.selected){
        fillColor = self.selectedColor;
    }else{
        fillColor = self.defaultColor;
    }
    
    [fillColor setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRect:self.bounds];
    [[NSColor blackColor]setStroke];
    [outlinePath setLineWidth:1];
    [outlinePath stroke];
}


@end
